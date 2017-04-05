--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid (mappend)
import           Hakyll
import           System.FilePath (takeDirectory, replaceExtension)
import           System.Directory (getDirectoryContents)
import           Data.Maybe (fromMaybe)
import           Data.Char (isDigit)
import           Control.Monad.ListM (sortByM)
import qualified Data.Map as M
import qualified Text.Pandoc as Pandoc
import           System.Process (callProcess)
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
          >>= readPandoc
          >>= (return . fmap (Pandoc.writeLaTeX Pandoc.def))
          >>= applyTemplate cvTpl defaultContext
          >>= pdflatex
          
--------------------------------------------------------------------------------
     
pdflatex :: Item String -> Compiler (Item TmpFile)
pdflatex item = do
  TmpFile texPath <- newTmpFile "cv.tex"
  
  let tmpDir = takeDirectory texPath
      pdfPath = replaceExtension texPath "pdf"
  
  unsafeCompiler $ do
    writeFile texPath $ itemBody item
    _ <- callProcess "pdflatex" ["-output-directory", tmpDir, texPath, ">/dev/null", "2>&1"]
    return $ ()
    
  makeItem $ TmpFile pdfPath

