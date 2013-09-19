ZIP=zip -r
RM=rm -rf

GAME=game.love
SOURCE=*.lua hump atl res
EXCLUDE = *.git*

game.love:
	$(ZIP) $@ $(SOURCE) -x $(EXCLUDE)

all: game.love

clean:
	$(RM) $(GAME) 
