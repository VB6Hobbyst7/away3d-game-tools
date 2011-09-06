package CameraAndCharacterControl
{

	import agt.controllers.entities.character.AnimatedCharacterEntityController;
	import agt.physics.PhysicsScene3D;
	import agt.physics.entities.CharacterEntity;

	import away3d.animators.data.SkeletonAnimationSequence;
	import away3d.animators.data.SkeletonAnimationState;
	import away3d.entities.Mesh;

	public class HellKnight
	{
		public var baseMesh:Mesh;
		public var entity:CharacterEntity;
		public var controller:AnimatedCharacterEntityController;

		public function HellKnight(mesh:Mesh, scene:PhysicsScene3D, idleAnimation:SkeletonAnimationSequence, walkAnimation:SkeletonAnimationSequence)
		{
			// get mesh
			baseMesh = mesh;
			// transform is controlled by animator
			var middleMesh:Mesh = new Mesh();
			middleMesh.rotationY = -180;
			middleMesh.scale(6);
			middleMesh.moveTo(0, -400, 20);
			middleMesh.addChild(baseMesh);
			var playerMesh:Mesh = new Mesh();
			// transform is controlled by AWP
			playerMesh.addChild(middleMesh); // TODO: Can simplify hierarchy here?

			// setup player
			entity = new CharacterEntity(playerMesh, 150 * playerMesh.scaleX, 500 * playerMesh.scaleX);
			entity.character.jumpSpeed = 4000;
			scene.addCharacterEntity(entity);

			// player controller
			controller = new AnimatedCharacterEntityController(entity, baseMesh.animationState as SkeletonAnimationState);
			controller.addAnimationSequence(walkAnimation);
			controller.addAnimationSequence(idleAnimation);
			controller.stop();
			controller.speedEase = 0.25;
			controller.animatorTimeScaleFactor = 0.03;
		}
	}
}
