package age.camera.controllers
{

import age.camera.events.CameraControllerEvent;
import age.input.InputContext;

import away3d.containers.ObjectContainer3D;

import flash.geom.Vector3D;

public class OrbitCameraController extends CameraControllerBase
{
	private var _target:ObjectContainer3D;
	private var _targetSphericalCoordinates:Vector3D;
	private var _currentSphericalCoordinates:Vector3D;

    private var _minElevation:Number = -Math.PI/2;
    private var _maxElevation:Number = Math.PI/2; // Elevation range should stay within [-Pi/2, Pi/2].

	public function OrbitCameraController(camera:ObjectContainer3D, target:ObjectContainer3D = null)
	{
		this.target = target || new ObjectContainer3D();
		super(camera);
	}

	override public function addInputContext(context:InputContext):void
	{
		super.addInputContext(context);
		registerEvent(CameraControllerEvent.MOVE_Z, moveRadius);
		registerEvent(CameraControllerEvent.ROTATE_Y, moveAzimuth);
		registerEvent(CameraControllerEvent.ROTATE_X, moveElevation);
	}

	override public function update():void
	{
		super.update();

		_targetSphericalCoordinates.y = containValue(_targetSphericalCoordinates.y, _minElevation, _maxElevation);

		var dx:Number = _targetSphericalCoordinates.x - _currentSphericalCoordinates.x;
		var dy:Number = _targetSphericalCoordinates.y - _currentSphericalCoordinates.y;
		var dz:Number = _targetSphericalCoordinates.z - _currentSphericalCoordinates.z;
		_currentSphericalCoordinates.x += dx * angularEase;
		_currentSphericalCoordinates.y += dy * angularEase;
		_currentSphericalCoordinates.z += dz * linearEase;
		_camera.position = sphericalToCartesian(_currentSphericalCoordinates);
		_camera.lookAt(_target.position);
	}

	public function moveAzimuth(amount:Number):void
	{
		_targetSphericalCoordinates.x += amount;
	}

	public function moveElevation(amount:Number):void
	{
		_targetSphericalCoordinates.y += amount;
	}

	public function moveRadius(amount:Number):void
	{
		_targetSphericalCoordinates.z += amount;
	}

	private function containValue(value:Number, min:Number, max:Number):Number
    {
        if(value < min)
            return min;
        else if(value > max)
            return max;
        else
            return value;
    }

	public function get target():ObjectContainer3D
	{
		return _target;
	}
	public function set target(value:ObjectContainer3D):void
	{
		_target = value;
	}

	override public function set camera(value:ObjectContainer3D):void
	{
		super.camera = value;
		_targetSphericalCoordinates = cartesianToSpherical(_camera.position);
		_currentSphericalCoordinates = _targetSphericalCoordinates.clone();
	}

	private function sphericalToCartesian(sphericalCoords:Vector3D):Vector3D
    {
        var cartesianCoords:Vector3D = new Vector3D();
        var r:Number = sphericalCoords.z;
        cartesianCoords.y = _target.y + r*Math.sin(-sphericalCoords.y);
        var cosE:Number = Math.cos(-sphericalCoords.y);
        cartesianCoords.x = _target.x + r*cosE*Math.sin(sphericalCoords.x);
        cartesianCoords.z = _target.z + r*cosE*Math.cos(sphericalCoords.x);
        return cartesianCoords;
    }

    private function cartesianToSpherical(cartesianCoords:Vector3D):Vector3D
    {
        var cartesianFromCenter:Vector3D = new Vector3D();
        cartesianFromCenter.x = cartesianCoords.x - _target.x;
        cartesianFromCenter.y = cartesianCoords.y - _target.y;
        cartesianFromCenter.z = cartesianCoords.z - _target.z;
        var sphericalCoords:Vector3D = new Vector3D();
        sphericalCoords.z = cartesianFromCenter.length;
        sphericalCoords.x = Math.atan2(cartesianFromCenter.x, cartesianFromCenter.z);
        sphericalCoords.y = -Math.asin((cartesianFromCenter.y)/sphericalCoords.z);
        return sphericalCoords;
    }
}
}