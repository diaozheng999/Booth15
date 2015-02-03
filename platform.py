import copy
import pygame
from imagereps import *
import sys


#making huge change: letting engine handle collisions
#1. removing player.checkobstaclesX, Y
#2. removing player.checkobs from update
#3. Creating a self.checkCollisions in engine.mainloop()
#** jump requires self.engine? or not
#3a. Added checkobstacleX,Y for player
#4. changing all the self.player.level into self.level
#5. removing self.level.player
#6. adding monster platform check to checkobstacleX,y (now is a group)
#** think about how self.chargroup interacts with the redraw and see if its necessary for other stuff
#7. create a self.monsterGroup so can check for monster and player interaction
#8. did the same changes for monster.update() -> removed self.checkobstx, y
#9. added a monster.die() more important, if player collides with monster, monster gets removed from group, and dies
#10. changed level to not init with player
#11 . ported changes look okay, now trying to fix collisions without having to break up into udpatex, updatey
#12. another problem: monster redraw is messing up
#13. figured it out. it was because monsterlist was updating twice per frameself
# 	solution: put the updatecalls in 1 big group, engine.update()
#14. removed self.level.update in favour of self.level.platform.update() and self.level.exitlist.update()
#15. important fix for update. characters update very differently from platform/level. They still call the 
#	engine function, but they check collisions differentlyfor each axis.
#16.assignment of engine to monster changes to take place in loadlevel,together with self.level.engine assignment

#17. collision between monster and player(unsovled yet)

#18. changing the coordinatesof the screen doesnt seem to change the drawFull function
#	strange cos the size of image of bgimg justbefore blit is tied to the window size

#19 tried to change the gravity function for dead sprites. now if self.dead == True, then gravity just increases dy by 2 each tick
#implemented Monster.die()

#need to fix: collision

#will change collide to take a player

#removed winlevel, merged into wincheck whichtakes place after collisions
#implemented the left and right facing images

#now wondering why monster falls are dy=70 and also why there are holes  in my platforms
#found a fix: if self.dy >30, self.dy =0 or something low.

#gravity fixed. holes in platform STILL exist. have no ideawhy though.

#1 get images for background
#2 get actuallevels
#3 fix collision between monsters andhumans

#think about moving platforms
# in preparation for time reverse, i added engine.reverse()
# in initanimation, i added self.charPositions=[], self.monstersPositions = []
# also need redolist?
#possible ideas: in charUpdate, levelupdate, store each of the old positions in the undo lists

#problem: dy is BUILDING UP as you stand on platforms. so when u fall you fall immediately at high lvl of dy
#solved problem by setting dy=0 in ycollide when collider is standing on platform
#changed: chargroup.draw override with player.draw.
#changed: turns out mosnter was being drawn twice with level.draw AND chargroup.draw. seems like dont need to usechargroup.draw

#problems: how to get reverse to proc while key is held down? pygame.key.set_repeat does not seem to do it
#theproblem is, while holding, no events are beingcalled. a soltion is calling get_pressed[pygame.K_LSHIFT], but that has to be down outside the for event loop
#which is messy, i think.

#mechanic changed to: shift turns on/off reverse mode

#now, for some reason self.rect.x is always constant in storePos
#doing self.player.dx = -reversedpositionX
#self.player.dy = -reversedpositionY works. (but its currently set to off.) Now, we have reverse setting self.rect.x to reversed position
#but not fully. Need to understand how the update stuff works.

#works. took deepcopy of the player.rect
#now trying to make mosnter work as well. works! thanks to deepcopy. 
#reversed deaths as wellby storing deaths in storedPos
#things to sort out
#colliision btw human and monster
#human death
#draw function for reverse 
#load image for nreversetime
#backgrounds , platform images.



class Player(pygame.sprite.Sprite):
	def __init__(self, width, height):
		super(Player, self).__init__()
		self.engine = None
		self.width = width
		self.height = height
		#we import the image from my image repository file
		self.picture = braidchar
		#and then we resize it
		#whatever the size of the picture, we scale it into the width and height desired
		self.picture = pygame.transform.scale(self.picture, (self.width, self.height))
		self.dx ,self.dy,self.oldx,self.oldy = 0,0,0,0
		#self.winLevel=False
		self.rect = self.picture.get_rect()
		#use a surface so as to make the background transparent
		self.imager = pygame.Surface((self.width, self.height))
		self.imager.blit(self.picture, (0,0))
		#makes the background of picture transparent
		self.imager.set_colorkey([255,255,255])
		self.imagel = pygame.transform.flip(self.imager, True, False)
		self.image = self.imager
		self.dead = False
		#makes the entire image surface more transparent
		#self.image.set_alpha(128)
		self.screenx = pygame.display.get_surface().get_width()
		self.screeny = pygame.display.get_surface().get_height()


	def update(self): #moving
		# Gravity
		#if self.engine.inreverse == False:
		self.gravity()
		# Move left/right
		self.oldx= self.rect.x
		self.rect.x += self.dx
		if self.rect.right >= self.screenx:
			self.rect.right = self.screenx
		elif self.rect.x< 0:
			self.rect.left = 0
		self.engine.xCollide(self)
		self.oldy = self.rect.y
		self.rect.y += self.dy
		self.engine.yCollide(self)		

	def draw(self,screen):
	 		screen.blit(self.image, (self.rect.x,self.rect.y))
 
	def gravity(self):
		if self.dead == False:
			if self.dy == 0:
				self.dy = 0.1
			if self.dy >= 30:
				self.dy = -0.1
			self.dy += 0.3
				#hit the ground
			if self.rect.y >= self.screeny - self.rect.height and self.dy >= 0:
				self.dy = 0
				self.rect.y = self.screeny - self.rect.height
 		else:
 			if self.dy <= 6:
 				self.dy +=1



	def jump(self):
 
		# move down a bit and see if there is a platform below us.
		# Move down 2 pixels because it doesn't work well if we only move down 1
		# when working with a platform moving down.
		self.rect.y += 2
		platformhitlist = pygame.sprite.spritecollide(self, self.engine.level.platformlist, False)
		self.rect.y -= 2
 		
		# If it is ok to jump, set our speed upwards
		if len(platformhitlist) > 0 or self.rect.bottom >= self.screeny:
			self.dy = -8

 	#keyleft,right, k_keyup
	def go_left(self):
		self.dx = -5
		self.image = self.imagel
 
	def go_right(self):
		self.dx = 5
		self.image=self.imager
 
	def stop(self):
		self.dx = 0


class Monster(Player):
	def __init__(self, width, height):
		super(Monster,self).__init__(width, height)
		self.engine = None
		self.picture = braidhog
		self.picture = pygame.transform.scale(self.picture, (self.width, self.height))
		self.imager = pygame.Surface((self.width, self.height))
		self.imager.blit(self.picture, (0,0))
		self.imager.set_colorkey([255,255,255])
		self.imagel = pygame.transform.flip(self.imager,True,False)
		self.image = self.imager
		self.rect = self.picture.get_rect()
		self.dead = False
		self.dx = 2
		self.screenx = pygame.display.get_surface().get_width()
		self.screeny = pygame.display.get_surface().get_height()

	def update(self): 
#		if self.engine.inreverse == False:
		self.gravity()
		# Move left/right
		if self.dead == False:
			self.oldx= self.rect.x
			self.rect.x += self.dx
			if self.rect.right >=self.screenx:
				self.dx = -2
				self.image = self.imagel
				
			elif self.rect.x < 0:
				self.dx = 2
				self.image = self.imager
			self.engine.xCollide(self)	
			self.oldy = self.rect.y
			self.rect.y += self.dy
			self.engine.yCollide(self)
		else:
			self.oldx = self.rect.x
			self.rect.x += self.dx
			self.oldy = self.rect.y
			self.rect.y +=self.dy




	def die(self):
		self.dy = 1

	#inherits gravity, update, checkobs leftright, jump, moveleft,moveright
 
class Platform(pygame.sprite.Sprite):
	def __init__(self, width, height):
		super(Platform, self).__init__()
 
		self.image = pygame.Surface([width, height])
		self.image.fill((255,0,255))
		self.rect = self.image.get_rect()

class LevelExit(pygame.sprite.Sprite):
	def __init__(self,width,height):
		super(LevelExit, self).__init__()
		self.image = pygame.Surface([width, height])
		self.image.fill((0,255,0))
		self.rect = self.image.get_rect()
 

class Level(object):
	def __init__(self):
		#this is the list of all the platforms in thegame
		self.platformlist = pygame.sprite.Group()
		self.engine = None
		#this is the door to the exit
		self.exitlist = pygame.sprite.Group()
		self.monsterlist = pygame.sprite.Group()
		#self.enemy_list = pygame.sprite.Group()

		self.screenx = pygame.display.get_surface().get_width()
		self.screeny = pygame.display.get_surface().get_height()
		# when subclassing this class, be sure to init self.bgimg to be an image file!
		self.bgimg = pygame.transform.scale(self.bgimg, (self.screenx, self.screeny))

	def drawFull(self, screen):#draws thefull background, once.
		screen.blit(self.bgimg, (0,0))

	def addLevelThings(self, levellist, exitlist, monsterlist):
		for platform in levellist:
			obstacle = Platform(platform[2], platform[3])
			obstacle.rect.x = platform[0]
			obstacle.rect.y = platform[1]
			#to check for collisions? nope. dont know why. can re-add though
			#block.player = self.player
			self.platformlist.add(obstacle)
		for exit in exitlist:
			door = LevelExit(exit[2], exit[3])
			door.rect.x = exit[0]
			door.rect.y = exit[1]
			self.exitlist.add(door)
		for monster in monsterlist:
			newmonster = Monster(monster[2],monster[3])
			newmonster.rect.x = monster[0]
			newmonster.rect.y = monster[1]
			newmonster.engine = self.engine
 			self.monsterlist.add(newmonster)
 
	def draw(self, screen):
		#this function is used to draw everything on the level into the screen

		#redraws part of the screen equal to the previous location of the player
		#thisonly draws the screen, not the player
		screen.blit(self.bgimg,(self.engine.player.oldx, self.engine.player.oldy),
								(self.engine.player.oldx, self.engine.player.oldy, self.engine.player.width, self.engine.player.height))

		for monster in self.monsterlist:
			screen.blit(self.bgimg, (monster.oldx, monster.oldy),(monster.oldx, monster.oldy, monster.width, monster.height))

		#does the same for the monster
		# Draw all the sprite lists that we have
		self.platformlist.draw(screen)
		self.exitlist.draw(screen)
		self.monsterlist.draw(screen)
		#self.enemy_list.draw(screen)
 
class Level1(Level):
	def __init__(self):
		self.level=1
		self.bgimg = levelbackgrounds[0]
		super(Level1,self).__init__()
		#list of platforms to draw
		levellist = [[300,500, 30, 50],
					[200,400,100,50],
					[350,300, 100,50],
					[430,200,300,50],
					[500,500, 30, 50],
					[0,500,100,50],
					[550,120,350,50],
					[800,300,200,50],
					[666, 450, 200,50]]
		#list of exit doors (suposed to have only 1)
		exitlist = [[100,100,100,100]]
		#list of monsters and other stuff
		monsterlist = [[600,90,30,30], [640,500,30,30]]
		#can also have other characters like cannon,etc
		self.addLevelThings(levellist, exitlist, monsterlist)
		#player information
		self.spawnx = 100
		self.spawny = self.screeny


class Level2(Level):
	def __init__(self):
		self.level=2
		self.bgimg = levelbackgrounds[1]
		super(Level2,self).__init__()
		level = [[250,300, 30, 50],
					[350,400,30,50],
					[134,310,200,50],
					[100,450, 30, 50]]

		exitlist = [[0,0,100,100]]

		monsterlist = []
		self.addLevelThings(level,exitlist, monsterlist)
		#player information
		self.spawnx = 500
		self.spawny = self.screeny


 
class Engine(object):
	def __init__(self, screenx, screeny):
		self.screenx = screenx
		self.screeny = screeny

	def initAnimation(self):
		self.bg = pygame.display.set_mode((self.screenx, self.screeny))
		pygame.display.set_caption("Testing run")
		self.fps = 40
		pygame.key.set_repeat(int(1000.0/self.fps),int(1000.0/self.fps))
		#initialise the player object as an attribute of the Engine object
		self.player = Player(45,45)
		self.player.engine = self
		#initialise a list of levels to add
		self.levellist = []
		#add the levels into it.(so far only1)
		level1 = Level1()
		level2= Level2()
		self.levellist.append(level1)
		self.levellist.append(level2)
		#initialise current level
		#self.currlevel is an attribute of the EngineObject
		self.currlevel = 1
		#clock stuff
		self.clock = pygame.time.Clock()
		self.storedPositions = []
		self.inreverse = False





	def eventHandler(self,event):
		if event.type == pygame.QUIT:
			pygame.quit()
			sys.exit()
		elif event.type == pygame.KEYDOWN:
			if self.inreverse == False:
				if event.key == pygame.K_LEFT:
					self.player.go_left()
				elif event.key == pygame.K_RIGHT:
					self.player.go_right()
				elif event.key == pygame.K_UP:
					self.player.jump()
				elif event.key == pygame.K_n:
					if self.currlevel < len(self.levellist):
						self.currlevel +=1
						self.loadLevel()
				elif event.key == pygame.K_m:
					if self.currlevel > 1:
						self.currlevel -= 1
						self.loadLevel()
			if event.key == pygame.K_LSHIFT:
				if self.inreverse == True:
					self.inreverse=False
				elif self.inreverse ==False:
					self.inreverse=True
		elif event.type == pygame.KEYUP:
			if event.key == pygame.K_LEFT and self.player.dx < 0:
				self.player.stop()
			if event.key == pygame.K_RIGHT and self.player.dx > 0:
				self.player.stop()


	def reverse(self):
		if len(self.storedPositions) > 0:
			reversedPositions = self.storedPositions.pop()
			#print len(self.storedPositions),reversedPositions[0]["rect"][0],reversedPositions[0]["rect"][1]
			self.player.rect.x = reversedPositions[0]["rect"][0]
			self.player.rect.y = reversedPositions[0]["rect"][1]
			self.player.dx = -reversedPositions[0]["dx"]
			self.player.dy = -reversedPositions[0]["dy"]
			print reversedPositions

			#So we cannot loop across monsterlist
			counter=-1
			for thing in self.level.monsterlist:
				counter+=1
				thing.rect.x= reversedPositions[1]["rect"][counter][0]
				thing.rect.y= reversedPositions[1]["rect"][counter][1]
				thing.dead = reversedPositions[1]["dead"][counter]
				



		if len(self.storedPositions)==0:
			self.inreverse = False

	


	def redrawAll(self):
		#level background redrawn first before the characters are drawn
		self.level.draw(self.bg)
		#self.player.draw is just overriding the sprite class draw
		#calling group.draw also works, it doesnt matter.
		self.player.draw(self.bg)
		#self.charGroup.draw(self.bg)	
		#below is prototype of colorchange when self.reverse is in motion
		#if self.inreverse:
		#	self.timeflip = pygame.Surface((self.screenx,self.screeny))
		#	colorbg = (240,240,240) 
		#	self.timeflip.fill(colorbg)
		#	self.timeflip.set_alpha(10)
		#	self.bg.blit(self.timeflip, (0,0))
		pygame.display.flip()


	def loadLevel(self):
		self.level = self.levellist[self.currlevel-1]
		self.level.engine  = self
		#add the player into the objects
		self.charGroup = pygame.sprite.Group()
		self.player.rect.x = self.level.spawnx
		self.player.rect.y = self.level.spawny - self.player.height
		self.charGroup.add(self.player)
		for monster in self.level.monsterlist:
			monster.engine = self
		self.level.bgimg = levelbackgrounds[self.currlevel-1]
		#this draws the level's bg image onto the display
		self.level.drawFull(self.bg)
		#this draws the level's stuff onto the background
		self.level.draw(self.bg)

	def xCollide(self,sprite):
		#this is checkObstaclesX, now with monsters as well
		platformcollidelist = pygame.sprite.spritecollide(sprite, self.level.platformlist, False,False)
		for platform in platformcollidelist:
			# If we are moving right,
			# set our right side to the left side of the item we hit
			if sprite.dx > 0:
				sprite.rect.right = platform.rect.left
			elif sprite.dx < 0:
				sprite.rect.left = platform.rect.right

		#if we reach the exit, we go to the next level		
	def wincheck(self):	
		exit = pygame.sprite.spritecollide(self.player, self.level.exitlist, False)
		if len(exit) >0:
			if self.currlevel <len(self.levellist):
				self.currlevel+=1
				self.loadLevel()
			else: #if no next level
				pass

	def yCollide(self, sprite):
		#this is check obstacles Y
		platformcollidelist = pygame.sprite.spritecollide(sprite, self.level.platformlist, False,False)
		for platform in platformcollidelist:
 
			if sprite.dy > 0:
				sprite.rect.bottom = platform.rect.top
				sprite.dy = 0
			elif sprite.dy< 0:
				sprite.rect.top = platform.rect.bottom				
				sprite.dy = 0

		
	def charCollisions(self):
		playermonstercollidelist = pygame.sprite.spritecollide(self.player, self.level.monsterlist, False )
		for sprite in playermonstercollidelist:
			#this is okay because its still in monster group
			sprite.dead = True
			sprite.die()

	def charsUpdate(self):
		self.player.update()
		for monster in self.level.monsterlist:
			monster.update()


	def levelUpdate(self):
		#the main level updating function. the nonmoving parts update here
		#only group have the update function
		#make sure that no sprite is contained in more than 1 updating group
		self.level.platformlist.update()
		self.level.exitlist.update()

	def storePos(self):
		#stores the variables in a list? dict?
		#need self.player.rect, self.player.dx, self.player.dy
		#need self.monster.rect, self.monster.dx, self.monster.dy
		#need self.level.platformlist
		#need self.level.exitlist
		playerdict = {"rect":copy.deepcopy(self.player.rect), "dx":self.player.dx,"dy":self.player.dy}
		monsterrectlist = []
		monsterdxlist = []
		monsterdylist = []
		monsterdeadlist = []

		for monster in self.level.monsterlist:
			monsterrectlist.append(copy.copy(monster.rect))
			monsterdxlist.append(monster.dx)
			monsterdylist.append(monster.dy)
			monsterdeadlist.append(monster.dead)
		monsterdict = {"rect":monsterrectlist, "dx":monsterdxlist, "dy":monsterdylist, "dead":monsterdeadlist}
		self.storedPositions.append((playerdict,monsterdict))

		




	def main(self):
		pygame.init()
		#initialise for the first time
		self.initAnimation()
		#then we load the level
		self.loadLevel()
		while True:
			for event in pygame.event.get(): 
				self.eventHandler(event)
			#print self.inreverse
			#if not self.inreverse:
#char updates contain platform collisions
			if self.inreverse == False:
				self.levelUpdate() #doesnt do much for playforms atm
				self.charsUpdate() #also gravity,resolving velocity and the like. Changes the 
				self.charCollisions()
				self.wincheck()
				self.storePos()
			elif self.inreverse == True:
				self.reverse()
				self.charsUpdate()
			self.redrawAll()
			
		
			#checks if we reached the exit door
			self.clock.tick(self.fps)

		pygame.quit()
		sys.exit()

def playGame(w,h):
	Engine(w,h).main()

playGame(900,600)



