// Three.js r184 - Node System

// directives


// structs


// uniforms

struct NodeBuffer_269872Struct {
	value : array< mat4x4<f32>, 16 >
};
@binding( 9 ) @group( 1 )
var<uniform> NodeBuffer_269872 : NodeBuffer_269872Struct;

struct renderStruct {
	cameraProjectionMatrix : mat4x4<f32>,
	cameraViewMatrix : mat4x4<f32>,
	nodeUniform16 : vec3<f32>,
	nodeUniform18 : vec3<f32>,
	nodeUniform15 : vec3<f32>,
	nodeUniform22 : vec3<f32>,
	nodeUniform33 : vec3<f32>,
	nodeUniform20 : vec3<f32>,
	nodeUniform21 : vec3<f32>,
	nodeUniform31 : vec3<f32>,
	nodeUniform32 : vec3<f32>,
	nodeUniform23 : mat4x4<f32>,
	nodeUniform24 : f32,
	nodeUniform25 : f32,
	nodeUniform29 : f32,
	nodeUniform40 : vec3<f32>,
	nodeUniform41 : f32,
	nodeUniform27 : f32,
	nodeUniform28 : vec2<f32>
};
@binding( 0 ) @group( 0 )
var<uniform> render : renderStruct;

struct objectStruct {
	nodeUniform1 : vec3<f32>,
	nodeUniform3 : mat3x3<f32>,
	nodeUniform4 : f32,
	nodeUniform5 : f32,
	nodeUniform6 : f32,
	nodeUniform7 : f32,
	nodeUniform9 : mat3x3<f32>,
	nodeUniform10 : f32,
	nodeUniform11 : vec3<f32>,
	nodeUniform12 : f32,
	nodeUniform13 : vec3<f32>,
	nodeUniform14 : f32,
	nodeUniform19 : mat4x4<f32>,
	nodeUniform34 : f32,
	nodeUniform35 : mat4x4<f32>,
	nodeUniform36 : f32,
	nodeUniform37 : f32,
	nodeUniform39 : f32
};
@binding( 0 ) @group( 1 )
var<uniform> object : objectStruct;

// varyings

struct VaryingsStruct {
	@location( 0 ) v_positionView : vec3<f32>,
	@location( 1 ) v_normalViewGeometry : vec3<f32>,
	@location( 2 ) v_positionViewDirection : vec3<f32>,
	@location( 3 ) v_positionWorld : vec3<f32>,
	@location( 4 ) nodeVarying7 : vec2<f32>,
	@builtin( position ) builtinClipSpace : vec4<f32>
};
var<private> varyings : VaryingsStruct;

// vars
var<private> normalLocal : vec3<f32>;
var<private> modelViewMatrix : mat4x4<f32>;
var<private> VERTEX_nodeVar213 : vec4<f32>;
var<private> positionLocal : vec3<f32>;
var<private> v_modelViewProjection : vec4<f32>;
var<private> VERTEX_v_modelViewProjection : vec4<f32>;

// codes


@vertex
fn main( @builtin( instance_index ) instanceIndex : u32,
	@location( 0 ) position : vec3<f32>,
	@location( 1 ) normal : vec3<f32>,
	@location( 2 ) uv : vec2<f32> ) -> VaryingsStruct {

	// flow
	// code

	positionLocal = position;
	positionLocal = ( NodeBuffer_269872.value[ instanceIndex ] * vec4<f32>( positionLocal, 1.0 ) ).xyz;
	normalLocal = normal;
	normalLocal = ( mat3x3<f32>( NodeBuffer_269872.value[ instanceIndex ][ 0 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 1 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 2 ].xyz ) * ( normalLocal / vec3<f32>( dot( mat3x3<f32>( NodeBuffer_269872.value[ instanceIndex ][ 0 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 1 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 2 ].xyz )[ 0u ], mat3x3<f32>( NodeBuffer_269872.value[ instanceIndex ][ 0 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 1 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 2 ].xyz )[ 0u ] ), dot( mat3x3<f32>( NodeBuffer_269872.value[ instanceIndex ][ 0 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 1 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 2 ].xyz )[ 1u ], mat3x3<f32>( NodeBuffer_269872.value[ instanceIndex ][ 0 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 1 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 2 ].xyz )[ 1u ] ), dot( mat3x3<f32>( NodeBuffer_269872.value[ instanceIndex ][ 0 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 1 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 2 ].xyz )[ 2u ], mat3x3<f32>( NodeBuffer_269872.value[ instanceIndex ][ 0 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 1 ].xyz, NodeBuffer_269872.value[ instanceIndex ][ 2 ].xyz )[ 2u ] ) ) ) );
	varyings.nodeVarying7 = uv;
	varyings.v_normalViewGeometry = normalize( ( render.cameraViewMatrix * vec4<f32>( ( object.nodeUniform9 * normalLocal ), 0.0 ) ).xyz );
	modelViewMatrix = ( render.cameraViewMatrix * object.nodeUniform19 );
	varyings.v_positionView = ( modelViewMatrix * vec4<f32>( positionLocal, 1.0 ) ).xyz;
	varyings.v_positionViewDirection = ( - varyings.v_positionView );
	varyings.v_positionWorld = ( object.nodeUniform19 * vec4<f32>( positionLocal, 1.0 ) ).xyz;
	VERTEX_nodeVar213 = ( render.cameraProjectionMatrix * vec4<f32>( varyings.v_positionView, 1.0 ) );
	VERTEX_v_modelViewProjection = VERTEX_nodeVar213;

	// result

	varyings.builtinClipSpace = VERTEX_v_modelViewProjection;

	return varyings;

}
