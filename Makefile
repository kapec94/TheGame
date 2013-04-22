ZIP=zip -r
RM=rm -rf

GAME=game.love

game.love: *.lua
	$(ZIP) $(GAME) *.lua res

all: game.love

clear:
	$(RM) $(GAME) 
