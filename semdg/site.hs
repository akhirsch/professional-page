---------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Data.Char (isDigit)
import           System.FilePath (takeDirectory, replaceExtension)
import           System.Directory (getDirectoryContents)
import           Data.Maybe (fromMaybe)
import           Control.Monad.ListM (sortByM)
import qualified Data.Map as M
import qualified Text.Pandoc as Pandoc
---------------------------------------------------------------------

main :: IO ()
main = hakyll $ do
     match "templates/*" $ compile templateCompiler
     match "images/*" $ do
         route   idRoute
         compile copyFileCompiler 
     match "css/*" $ do
         route   idRoute
         compile compressCssCompiler
     match "js/*" $ do 
         route   idRoute
         compile copyFileCompiler -- Minimizer?
     match "papers/*" $ do
         route $ setExtension "html"
         compile $ do
              semesters   <- loadAll ("semesters/*" .&&. hasVersion "raw") :: Compiler [Item CopyFile]
              md          <- getUnderlying >>= getMetadata 
              let semester = fromMaybe "No Semester" $ M.lookup "semester" md
              semesters'  <- mapM (sameSemester semester) semesters
              let (curSemester:_) = map fst (filter snd (zip semesters semesters'))
              md'         <- getMetadata (itemIdentifier curSemester)
              let ctx     = foldl (\c (ident, d) -> c `mappend` (constField ident d)) defaultContext (M.toList md')

              pandocCompiler
                >>= loadAndApplyTemplate "templates/paper.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
     match "semesters/*" $ version "raw" $ do
         route $ idRoute
         compile $ copyFileCompiler
     match "semesters/*" $ do
         route $ setExtension "html"
         compile $ getUnderlying >>= semesterCompiler
     create ["archive.html"] $ do
         route $ idRoute
         compile $ do
              sems <- loadAll ("semesters/*" .&&. hasNoVersion)
              let ctx = listField "semester" defaultContext (return sems) `mappend` defaultContext

              makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
 
     match "index.html" $ do 
         route $ idRoute
         compile $ do
              sems     <- loadAll ("semesters/*" .&&. hasNoVersion) :: Compiler [Item String]
              (cur:_)  <- sortByM semesterOrder sems
              curUrl   <- getMetadataField (itemIdentifier cur) "semester"
              let ctx = constField "cur" (fromMaybe "none" curUrl) `mappend` defaultContext
              
              getResourceBody
                >>= applyAsTemplate ctx
                >>= relativizeUrls

---------------------------------------------------------------------

semesterCompiler :: Identifier -> Compiler (Item String)
semesterCompiler id = do 
                   md           <- getMetadata id
                   papers'      <- loadAll "papers/*" >>= chronological
                   let semester = fromMaybe "No Semester" $ M.lookup "semester" md
                   papers''     <- mapM (sameSemester semester) papers'
                   let papers   = map fst (filter snd (zip papers' papers''))
                   let ctx      = listField "papers" defaultContext (return papers) `mappend` 
                                  foldl (\c (ident, d) -> c `mappend` (constField ident d)) defaultContext (M.toList md)
                   pandocCompiler
                     >>= loadAndApplyTemplate "templates/semester.html" ctx
                     >>= loadAndApplyTemplate "templates/default.html" ctx
                     >>= relativizeUrls

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

