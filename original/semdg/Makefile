all: site
	./site rebuild
site: site.hs
	ghc -o site site.hs
clean: site
	./site clean;rm site.hi site.o site