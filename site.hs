--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid (mappend)
import           Hakyll
import           System.Cmd (system)
import           System.FilePath (takeDirectory, replaceExtension)
import           System.Directory (getDirectoryContents)
import           Data.Maybe (fromMaybe)
import           Data.Char (isDigit)
import           Control.Monad.ListM (sortByM)
import qualified Data.Map as M
import qualified Text.Pandoc as Pandoc
--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "publications/*" $ do
        route idRoute
        compile copyFileCompiler
        
    match "pubs/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
          >>= loadAndApplyTemplate "templates/publication.html" defaultContext
          >>= loadAndApplyTemplate "templates/default.html" defaultContext
          >>= relativizeUrls
    
    create ["publications.html"] $ do
        route idRoute
        compile $ do
          pubs <- loadAll "pubs/*"
          let researchCtx = 
                constField "title" "Publications"                 `mappend`
                listField "pubs" defaultContext (return pubs)     `mappend`
                defaultContext
                
          makeItem ""
            >>= loadAndApplyTemplate "templates/publications.html" researchCtx
            >>= loadAndApplyTemplate "templates/default.html" researchCtx
            >>= relativizeUrls      
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
                    , "monads.markdown"
                    ]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls


    match "research/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/project.html" defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
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

    match "index.html" $ do
        route idRoute
        compile $ do
            prjcts <- loadAll "research/*"
            pubs   <- loadAll "pubs/*"
            let indexCtx = 
                    listField "prjcts" defaultContext (return . take 10 $ prjcts) `mappend`
                    listField "pubs" defaultContext (return . take 10 $ pubs)     `mappend`
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
    match "semdg/templates/*" $ compile templateCompiler
    match "semdg/images/*" $ do
        route   idRoute
        compile copyFileCompiler 
    match "semdg/css/*" $ do
        route   idRoute
        compile compressCssCompiler
    match "semdg/js/*" $ do 
        route   idRoute
        compile copyFileCompiler -- Minimizer?
    match "semdg/papers/*" $ do
        route $ setExtension "html"
        compile $ do
             semesters   <- loadAll ("semdg/semesters/*" .&&. hasVersion "raw") :: Compiler [Item CopyFile]
             md          <- getUnderlying >>= getMetadata 
             let semester = fromMaybe "No Semester" $ M.lookup "semester" md
             semesters'  <- mapM (sameSemester semester) semesters
             let (curSemester:_) = map fst (filter snd (zip semesters semesters'))
             md'         <- getMetadata (itemIdentifier curSemester)
             let ctx     = foldl (\c (ident, d) -> c `mappend` (constField ident d)) defaultContext (M.toList md')

             pandocCompiler
               >>= loadAndApplyTemplate "semdg/templates/paper.html" ctx
               >>= loadAndApplyTemplate "semdg/templates/default.html" ctx
               >>= relativizeSemdgUrls
    match "semdg/semesters/*" $ version "raw" $ do
        route $ idRoute
        compile $ copyFileCompiler
    match "semdg/semesters/*" $ do
        route $ setExtension "html"
        compile $ getUnderlying >>= semesterCompiler
    create ["semdg/archive.html"] $ do
        route $ idRoute
        compile $ do
             sems <- loadAll ("semdg/semesters/*" .&&. hasNoVersion)
             let ctx = listField "semester" defaultContext (return sems) `mappend` defaultContext

             makeItem ""
               >>= loadAndApplyTemplate "semdg/templates/archive.html" ctx
               >>= loadAndApplyTemplate "semdg/templates/default.html" ctx
               >>= relativizeSemdgUrls
 
    match "semdg/index.html" $ do 
        route $ idRoute
        compile $ do
             sems     <- loadAll ("semdg/semesters/*" .&&. hasNoVersion) :: Compiler [Item String]
             (cur:_)  <- sortByM semesterOrder sems
             curUrl   <- getMetadataField (itemIdentifier cur) "semester"
             let ctx = constField "cur" (fromMaybe "none" curUrl) `mappend` defaultContext
              
             getResourceBody
               >>= applyAsTemplate ctx
               >>= relativizeSemdgUrls


--------------------------------------------------------------------------------
     
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

semesterCompiler :: Identifier -> Compiler (Item String)
semesterCompiler id = do 
                   md           <- getMetadata id
                   papers'      <- loadAll "semdg/papers/*" >>= chronological
                   let semester = fromMaybe "No Semester" $ M.lookup "semester" md
                   papers''     <- mapM (sameSemester semester) papers'
                   let papers   = map fst (filter snd (zip papers' papers''))
                   let ctx      = listField "papers" defaultContext (return papers) `mappend` 
                                  foldl (\c (ident, d) -> c `mappend` (constField ident d)) defaultContext (M.toList md)
                   pandocCompiler
                     >>= loadAndApplyTemplate "semdg/templates/semester.html" ctx
                     >>= loadAndApplyTemplate "semdg/templates/default.html" ctx
                     >>= relativizeSemdgUrls


getPandocBody :: Item String -> String
getPandocBody = itemBody . writePandoc . readPandoc 

sameSemester :: String -> Item a -> Compiler Bool
sameSemester sem item = do
         sem' <- getMetadataField (itemIdentifier item) "semester"
         return (sem == (fromMaybe "No Semester") sem')

semesterOrder :: Item a -> Item a -> Compiler Ordering
semesterOrder i1 i2 = do
                      semester1 <- getMetadataField (itemIdentifier i1) "semester"
                      semester2 <- getMetadataField (itemIdentifier i2) "semester"
                      let s1 = fromMaybe "No Semester" semester1
                          s2 = fromMaybe "No Semester" semester2
                          y1 = takeWhile isDigit s1
                          y2 = takeWhile isDigit s2
                          sem1 = reverse $ takeWhile (not . isDigit) $ reverse s1
                          sem2 = reverse $ takeWhile (not . isDigit) $ reverse s2
                      if length y1 /= 4 || length y2 /= 4 || length sem1 /= 2 || length sem2 /= 2 -- malformed semesters are equal
                      then return EQ
                      else 
                         let y1Num = read y1 :: Integer
                             y2Num = read y2 :: Integer
                         in
                           if y1Num < y2Num
                           then return LT
                           else if y2Num < y1Num
                                then return GT
                                else if sem1 == "sp" && sem2 == "fa" then return GT else if sem2 == "sp" && sem1 == "fa" then return LT else return EQ

relativizeSemdgUrls :: Item String -> Compiler (Item String)
relativizeSemdgUrls item = do
     route <- getRoute $ itemIdentifier item
     return $ case route of
                Nothing -> item
                Just r -> fmap (relativizeUrlsWith $ ((toSiteRoot r) ++ "/semdg")) item
