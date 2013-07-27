ZIP=zip -r
RM=rm -rf

GAME=game.love

game.love: *.lua
	$(ZIP) $(GAME) *.lua hump atl res

all: game.love

clean:
	$(RM) $(GAME) 
