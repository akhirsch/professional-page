--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           System.Cmd (system)
import           System.FilePath (takeDirectory, replaceExtension)
import qualified Text.Pandoc as Pandoc
--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "publications/*" $ do
        route idRoute
        compile copyFileCompiler
      
    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler 
    
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.markdown"
                    , "contact.markdown"
                    ]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls
    
    match "posts/*.lhs" $ version "lhs" $ do
        route   idRoute
        compile getResourceBody 

    match "research/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/project.html" defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls
            
    match "trip_reports/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls
        
    create ["research.html"] $ do
        route idRoute
        compile $ do
          prjcts <- loadAll "research/*"
          let researchCtx = 
                constField "title" "Research"                     `mappend`
                listField "prjcts" defaultContext (return prjcts) `mappend`
                defaultContext
                
          makeItem ""
            >>= loadAndApplyTemplate "templates/research.html" researchCtx
            >>= loadAndApplyTemplate "templates/default.html" researchCtx
            >>= relativizeUrls

    create ["tripreports.html"] $ do
        route idRoute
        compile $ do
            rprts <- recentFirst =<< loadAll "trip_reports/*"
            let archiveCtx =
                    listField "rprts" reportCtx (return rprts) `mappend`
                    constField "title" "Trip Reports"          `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/trip_reports.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll ("posts/*" .&&. hasNoVersion)
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts  <- recentFirst =<< loadAll ("posts/*" .&&. hasNoVersion)
            prjcts <- loadAll "research/*"
            rprts  <- recentFirst =<< loadAll "trip_reports/*"
            let indexCtx = 
                    listField "posts" postCtx (return . take 10 $ posts)          `mappend`
                    listField "prjcts" defaultContext (return . take 10 $ prjcts) `mappend`
                    listField "rprts" reportCtx (return . take 10 $ rprts)        `mappend`
                    constField "title" "Home"                                     `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler
    
    match "cv.markdown" $ do
      route   $ setExtension "html"
      compile $ pandocCompiler 
        >>= loadAndApplyTemplate "templates/cv.html" defaultContext
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls
        
    match "cv.markdown" $ version "pdf" $ do
      route   $ setExtension "pdf"
      compile $ do
        cvTpl <- loadBody "templates/cv.tex"
        getResourceBody
          >>= (return . readPandoc)
          >>= (return . fmap (Pandoc.writeLaTeX Pandoc.def))
          >>= applyTemplate cvTpl defaultContext
          >>= pdflatex

    create["rss/posts.xml"] $ do
      route   idRoute
      compile $ do 
        let feedCtx = postCtx `mappend` bodyField "description"
        posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots ("posts/*" .&&. hasNoVersion) "content"
        renderRss postFeedConfig feedCtx posts
    
    create["rss/trip_reports.xml"] $ do
      route   idRoute
      compile $ do 
        let feedCtx = postCtx `mappend` bodyField "description"
        posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "trip_reports/*" "content"
        renderRss tripReportFeedConfig feedCtx posts


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

reportCtx :: Context String
reportCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

postFeedConfig :: FeedConfiguration
postFeedConfig = FeedConfiguration 
  { feedTitle = "Andrew Hirsch: Language and Logic: Posts"
  , feedDescription = "Posts from Andrew K. Hirsch's professional blog"
  , feedAuthorName = "Andrew K. Hirsch" 
  , feedAuthorEmail = "akhirsch@gwmail.gwu.edu"
  , feedRoot = "http://akhirsch.github.io/"
  }
  
tripReportFeedConfig :: FeedConfiguration
tripReportFeedConfig = FeedConfiguration 
  { feedTitle = "Andrew Hirsch: Language and Logic: Posts"
  , feedDescription = "Posts from Andrew K. Hirsch's Trip Reports"
  , feedAuthorName = "Andrew K. Hirsch" 
  , feedAuthorEmail = "akhirsch@gwmail.gwu.edu"
  , feedRoot = "http://akhirsch.github.io/"
  }
     
pdflatex :: Item String -> Compiler (Item TmpFile)
pdflatex item = do
  TmpFile texPath <- newTmpFile "cv.tex"
  
  let tmpDir = takeDirectory texPath
      pdfPath = replaceExtension texPath "pdf"
  
  unsafeCompiler $ do
    writeFile texPath $ itemBody item
    _ <- system $ unwords ["pdflatex", "-output-directory", tmpDir, texPath, ">/dev/null", "2>&1"]
    return $ ()
    
  makeItem $ TmpFile pdfPath

