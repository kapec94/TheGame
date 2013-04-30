ZIP=zip -r
RM=rm -rf

GAME=game.love

game.love: *.lua
	$(ZIP) $(GAME) *.lua hump 

all: game.love

clear:
	$(RM) $(GAME) 
