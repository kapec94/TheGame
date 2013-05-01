ZIP=zip -r
RM=rm -rf

GAME=game.love

game.love: *.lua
	$(ZIP) $(GAME) *.lua hump HardonCollider

all: game.love

clear:
	$(RM) $(GAME) 
