package states.stages;

import states.stages.objects.*;
import objects.Character;

class Robin extends BaseStage
{
	var robinForestuff:BGSprite;
	override function create() 
	{
		var sky:BGSprite = new BGSprite('stageImages/blockrock/sky',  -370, -270, 0.1, 0.1);
		sky.setGraphicSize(Std.int(sky.width * 0.9));
		sky.updateHitbox();
		add(sky);
		
		var trees:BGSprite = new BGSprite('stageImages/blockrock/trees', -810, 50, 0.5, 0.4);
		trees.setGraphicSize(Std.int(trees.width * 1.2));
		trees.updateHitbox();
		add(trees);

		var rockfloor:BGSprite = new BGSprite('stageImages/blockrock/rockfloor', -115, 1060, 1, 1);
		rockfloor.setGraphicSize(Std.int(rockfloor.width * 0.9));
		rockfloor.updateHitbox();
		add(rockfloor);
		
		var bush:BGSprite = new BGSprite('stageImages/blockrock/bush', -105, 870, 1, 1);
		bush.setGraphicSize(Std.int(bush.width * 0.9));
		bush.updateHitbox();
		add(bush);
		
		var house:BGSprite = new BGSprite('stageImages/blockrock/house', 30, 240);
		house.setGraphicSize(Std.int(house.width * 0.59));
		house.updateHitbox();
		add(house);
		
		var tree:BGSprite = new BGSprite('stageImages/blockrock/tree', 1280, 275, 0.9, 0.9);
		tree.setGraphicSize(Std.int(tree.width * 0.7));
		tree.updateHitbox();
		add(tree);	

		var stone:BGSprite = new BGSprite('stageImages/blockrock/stone', -170, 480, 0.9, 0.9);
		stone.setGraphicSize(Std.int(stone.width * 0.7));
		stone.updateHitbox();
		add(stone);
		
		robinForestuff = new BGSprite('stageImages/blockrock/forestuff', -200, 110, 0.4, 0.4);
		robinForestuff.setGraphicSize(Std.int(robinForestuff.width * 0.75));
		robinForestuff.updateHitbox();
			
	}
	override function createPost()
		{
			add(robinForestuff);
		}
}