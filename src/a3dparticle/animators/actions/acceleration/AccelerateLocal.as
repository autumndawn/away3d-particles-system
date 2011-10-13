package a3dparticle.animators.actions.acceleration 
{
	import a3dparticle.animators.actions.PerParticleAction;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	import away3d.materials.utils.ShaderRegisterElement;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author ...
	 */
	public class AccelerateLocal extends PerParticleAction
	{
		private var _accFun:Function;
		
		private var _tempAcc:Vector3D;
		
		private var accAttribute:ShaderRegisterElement;
		
		/**
		 * 
		 * @param	fun Function.The fun return a Vector3D that (x,y,z) is a acceleration.
		 */
		public function AccelerateLocal(fun:Function) 
		{
			dataLenght = 3;
			_accFun = fun;
		}
		
		override public function genOne(index:uint):void
		{
			_tempAcc = _accFun(index);
		}
		
		override public function distributeOne(index:int, verticeIndex:uint):void
		{
			_vertices.push(_tempAcc.x);
			_vertices.push(_tempAcc.y);
			_vertices.push(_tempAcc.z);
		}
		
		override public function getAGALVertexCode(pass : MaterialPassBase) : String
		{
			accAttribute = shaderRegisterCache.getFreeVertexAttribute();
			var temp:ShaderRegisterElement = shaderRegisterCache.getFreeVertexVectorTemp();
			shaderRegisterCache.addVertexTempUsages(temp,1);
			
			var code:String = "";
			
			code += "mul " + temp.toString() +"," + _animation.vertexTime.toString() + "," + accAttribute.toString() + "\n";
			
			if (_animation.needVelocity)
			{
				var temp2:ShaderRegisterElement = shaderRegisterCache.getFreeVertexVectorTemp();
				code += "mul " + temp2.toString() + "," + temp.toString() + "," + _animation.TwoConst.toString() + "\n";
				code += "add " + _animation.velocityTarget.toString() + ".xyz," + temp2.toString() + ".xyz," + _animation.velocityTarget.toString() + "\n";
			}
			shaderRegisterCache.removeVertexTempUsage(temp);
			
			code += "mul " + temp.toString() +"," + temp.toString() + "," + _animation.vertexTime.toString() + "\n";
			code += "add " + _animation.offestTarget.toString() +".xyz," + temp.toString() + "," + _animation.offestTarget.toString() + ".xyz\n";		
			return code;
		}
		
		override public function setRenderState(stage3DProxy : Stage3DProxy, pass : MaterialPassBase, renderable : IRenderable) : void
		{
			stage3DProxy.setSimpleVertexBuffer(accAttribute.index, getVertexBuffer(stage3DProxy), Context3DVertexBufferFormat.FLOAT_3);
		}
		
	}

}