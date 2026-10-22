// Three.js r184 - Node System

// global
diagnostic( off, derivative_uniformity );


// structs

struct OutputStruct {
	@location( 0 ) color: vec4<f32>
};
var<private> output : OutputStruct;

// uniforms
@binding( 1 ) @group( 1 ) var nodeUniform2_sampler : sampler;
@binding( 2 ) @group( 1 ) var nodeUniform2 : texture_2d<f32>;
@binding( 3 ) @group( 1 ) var nodeUniform26_sampler : sampler_comparison;
@binding( 4 ) @group( 1 ) var nodeUniform26 : texture_depth_2d;
@binding( 5 ) @group( 1 ) var nodeUniform30_sampler : sampler;
@binding( 6 ) @group( 1 ) var nodeUniform30 : texture_2d<f32>;
@binding( 7 ) @group( 1 ) var nodeUniform38_sampler : sampler;
@binding( 8 ) @group( 1 ) var nodeUniform38 : texture_2d<f32>;

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

// vars
var<private> DiffuseColor : vec4<f32>;
var<private> nodeVar0 : vec4<f32>;
var<private> Metalness : f32;
var<private> Roughness : f32;
var<private> normalViewGeometry : vec3<f32>;
var<private> nodeVar1 : vec3<f32>;
var<private> IOR : f32;
var<private> SpecularColor : vec3<f32>;
var<private> nodeVar2 : f32;
var<private> SpecularColorBlended : vec3<f32>;
var<private> SpecularF90 : f32;
var<private> DiffuseContribution : vec3<f32>;
var<private> EmissiveColor : vec3<f32>;
var<private> Output : vec4<f32>;
var<private> irradiance : vec3<f32>;
var<private> NORMAL_normalView : vec3<f32>;
var<private> normalView : vec3<f32>;
var<private> nodeVar3 : vec4<f32>;
var<private> nodeVar4 : vec4<f32>;
var<private> nodeVar5 : vec3<f32>;
var<private> normalWorld : vec3<f32>;
var<private> nodeVar6 : f32;
var<private> nodeVar7 : f32;
var<private> nodeVar8 : f32;
var<private> nodeVar9 : vec3<f32>;
var<private> nodeVar10 : vec3<f32>;
var<private> directDiffuse : vec3<f32>;
var<private> positionViewDirection : vec3<f32>;
var<private> nodeVar11 : vec3<f32>;
var<private> nodeVar12 : vec4<f32>;
var<private> nodeVar13 : vec4<f32>;
var<private> nodeVar14 : vec3<f32>;
var<private> nodeVar15 : vec3<f32>;
var<private> nodeVar16 : vec3<f32>;
var<private> nodeVar17 : vec3<f32>;
var<private> nodeVar18 : vec3<f32>;
var<private> nodeVar19 : vec3<f32>;
var<private> nodeVar20 : f32;
var<private> nodeVar21 : f32;
var<private> nodeVar22 : f32;
var<private> nodeVar23 : f32;
var<private> nodeVar24 : vec3<f32>;
var<private> shadowPositionWorld : vec3<f32>;
var<private> nodeVar25 : f32;
var<private> nodeVar26 : vec4<f32>;
var<private> nodeVar27 : vec3<f32>;
var<private> nodeVar28 : vec3<f32>;
var<private> nodeVar29 : f32;
var<private> nodeVar30 : f32;
var<private> nodeVar31 : vec2<f32>;
var<private> nodeVar32 : f32;
var<private> nodeVar33 : vec2<f32>;
var<private> nodeVar34 : f32;
var<private> nodeVar35 : vec2<f32>;
var<private> nodeVar36 : f32;
var<private> nodeVar37 : vec2<f32>;
var<private> nodeVar38 : f32;
var<private> nodeVar39 : vec2<f32>;
var<private> nodeVar40 : f32;
var<private> nodeVar41 : f32;
var<private> nodeVar42 : vec3<f32>;
var<private> nodeVar43 : vec3<f32>;
var<private> nodeVar44 : vec3<f32>;
var<private> nodeVar45 : vec3<f32>;
var<private> nodeVar46 : f32;
var<private> nodeVar47 : vec3<f32>;
var<private> nodeVar48 : vec3<f32>;
var<private> nodeVar49 : vec3<f32>;
var<private> nodeVar50 : vec3<f32>;
var<private> nodeVar51 : vec3<f32>;
var<private> directSpecular : vec3<f32>;
var<private> nodeVar52 : vec3<f32>;
var<private> nodeVar53 : f32;
var<private> nodeVar54 : f32;
var<private> nodeVar55 : f32;
var<private> nodeVar56 : vec4<f32>;
var<private> nodeVar57 : vec4<f32>;
var<private> nodeVar58 : vec3<f32>;
var<private> nodeVar59 : f32;
var<private> nodeVar60 : f32;
var<private> nodeVar61 : vec3<f32>;
var<private> nodeVar62 : vec3<f32>;
var<private> nodeVar63 : vec3<f32>;
var<private> nodeVar64 : vec3<f32>;
var<private> nodeVar65 : vec4<f32>;
var<private> nodeVar66 : vec4<f32>;
var<private> nodeVar67 : vec3<f32>;
var<private> nodeVar68 : vec3<f32>;
var<private> nodeVar69 : vec3<f32>;
var<private> nodeVar70 : vec3<f32>;
var<private> nodeVar71 : vec3<f32>;
var<private> nodeVar72 : vec3<f32>;
var<private> nodeVar73 : f32;
var<private> nodeVar74 : f32;
var<private> nodeVar75 : f32;
var<private> nodeVar76 : f32;
var<private> nodeVar77 : vec3<f32>;
var<private> nodeVar78 : vec3<f32>;
var<private> nodeVar79 : vec3<f32>;
var<private> nodeVar80 : vec3<f32>;
var<private> nodeVar81 : f32;
var<private> nodeVar82 : vec3<f32>;
var<private> nodeVar83 : vec3<f32>;
var<private> nodeVar84 : vec3<f32>;
var<private> nodeVar85 : vec3<f32>;
var<private> nodeVar86 : vec3<f32>;
var<private> nodeVar87 : vec3<f32>;
var<private> nodeVar88 : f32;
var<private> nodeVar89 : f32;
var<private> nodeVar90 : f32;
var<private> nodeVar91 : vec4<f32>;
var<private> nodeVar92 : vec4<f32>;
var<private> nodeVar93 : vec3<f32>;
var<private> nodeVar94 : f32;
var<private> nodeVar95 : f32;
var<private> nodeVar96 : vec3<f32>;
var<private> nodeVar97 : vec3<f32>;
var<private> nodeVar98 : vec3<f32>;
var<private> radiance : vec3<f32>;
var<private> nodeVar99 : f32;
var<private> nodeVar100 : f32;
var<private> nodeVar101 : f32;
var<private> nodeVar102 : vec3<f32>;
var<private> nodeVar103 : f32;
var<private> nodeVar104 : f32;
var<private> nodeVar105 : f32;
var<private> nodeVar106 : vec2<f32>;
var<private> nodeVar107 : vec4<f32>;
var<private> nodeVar108 : vec3<f32>;
var<private> nodeVar109 : f32;
var<private> nodeVar110 : f32;
var<private> nodeVar111 : f32;
var<private> nodeVar112 : f32;
var<private> nodeVar113 : f32;
var<private> nodeVar114 : vec2<f32>;
var<private> nodeVar115 : vec4<f32>;
var<private> nodeVar116 : vec3<f32>;
var<private> nodeVar117 : vec3<f32>;
var<private> iblIrradiance : vec3<f32>;
var<private> nodeVar118 : f32;
var<private> nodeVar119 : f32;
var<private> nodeVar120 : f32;
var<private> nodeVar121 : f32;
var<private> nodeVar122 : f32;
var<private> nodeVar123 : f32;
var<private> nodeVar124 : vec2<f32>;
var<private> nodeVar125 : vec4<f32>;
var<private> nodeVar126 : vec3<f32>;
var<private> nodeVar127 : f32;
var<private> nodeVar128 : f32;
var<private> nodeVar129 : f32;
var<private> nodeVar130 : f32;
var<private> nodeVar131 : f32;
var<private> nodeVar132 : vec2<f32>;
var<private> nodeVar133 : vec4<f32>;
var<private> nodeVar134 : vec3<f32>;
var<private> nodeVar135 : vec3<f32>;
var<private> nodeVar136 : vec3<f32>;
var<private> nodeVar137 : vec3<f32>;
var<private> nodeVar138 : vec3<f32>;
var<private> indirectDiffuse : vec3<f32>;
var<private> nodeVar139 : vec3<f32>;
var<private> singleScatteringDielectric : vec3<f32>;
var<private> multiScatteringDielectric : vec3<f32>;
var<private> singleScatteringMetallic : vec3<f32>;
var<private> multiScatteringMetallic : vec3<f32>;
var<private> nodeVar140 : f32;
var<private> nodeVar141 : vec4<f32>;
var<private> nodeVar142 : vec3<f32>;
var<private> nodeVar143 : f32;
var<private> nodeVar144 : vec3<f32>;
var<private> nodeVar145 : vec3<f32>;
var<private> nodeVar146 : vec3<f32>;
var<private> nodeVar147 : vec3<f32>;
var<private> nodeVar148 : vec3<f32>;
var<private> nodeVar149 : vec3<f32>;
var<private> nodeVar150 : vec3<f32>;
var<private> nodeVar151 : f32;
var<private> nodeVar152 : f32;
var<private> nodeVar153 : f32;
var<private> nodeVar154 : vec3<f32>;
var<private> nodeVar155 : vec3<f32>;
var<private> nodeVar156 : vec3<f32>;
var<private> nodeVar157 : vec3<f32>;
var<private> nodeVar158 : vec3<f32>;
var<private> nodeVar159 : vec3<f32>;
var<private> nodeVar160 : f32;
var<private> nodeVar161 : vec4<f32>;
var<private> nodeVar162 : vec3<f32>;
var<private> nodeVar163 : f32;
var<private> nodeVar164 : vec3<f32>;
var<private> nodeVar165 : vec3<f32>;
var<private> nodeVar166 : vec3<f32>;
var<private> nodeVar167 : vec3<f32>;
var<private> nodeVar168 : vec3<f32>;
var<private> nodeVar169 : vec3<f32>;
var<private> nodeVar170 : vec3<f32>;
var<private> nodeVar171 : f32;
var<private> nodeVar172 : f32;
var<private> nodeVar173 : f32;
var<private> nodeVar174 : vec3<f32>;
var<private> nodeVar175 : vec3<f32>;
var<private> nodeVar176 : vec3<f32>;
var<private> nodeVar177 : vec3<f32>;
var<private> nodeVar178 : vec3<f32>;
var<private> nodeVar179 : vec3<f32>;
var<private> nodeVar180 : vec3<f32>;
var<private> nodeVar181 : vec3<f32>;
var<private> nodeVar182 : vec3<f32>;
var<private> nodeVar183 : vec3<f32>;
var<private> nodeVar184 : vec3<f32>;
var<private> nodeVar185 : vec3<f32>;
var<private> nodeVar186 : vec3<f32>;
var<private> nodeVar187 : vec3<f32>;
var<private> nodeVar188 : vec3<f32>;
var<private> nodeVar189 : vec3<f32>;
var<private> nodeVar190 : vec3<f32>;
var<private> nodeVar191 : vec3<f32>;
var<private> nodeVar192 : vec3<f32>;
var<private> indirectSpecular : vec3<f32>;
var<private> nodeVar193 : vec3<f32>;
var<private> nodeVar194 : vec3<f32>;
var<private> ambientOcclusion : f32;
var<private> nodeVar195 : vec3<f32>;
var<private> nodeVar196 : f32;
var<private> nodeVar197 : f32;
var<private> nodeVar198 : f32;
var<private> nodeVar199 : f32;
var<private> nodeVar200 : f32;
var<private> nodeVar201 : f32;
var<private> nodeVar202 : f32;
var<private> nodeVar203 : f32;
var<private> nodeVar204 : f32;
var<private> nodeVar205 : f32;
var<private> nodeVar206 : f32;
var<private> nodeVar207 : vec3<f32>;
var<private> totalDiffuse : vec3<f32>;
var<private> nodeVar208 : vec3<f32>;
var<private> totalSpecular : vec3<f32>;
var<private> nodeVar209 : vec3<f32>;
var<private> outgoingLight : vec3<f32>;
var<private> nodeVar210 : vec3<f32>;
var<private> nodeVar211 : f32;
var<private> nodeVar212 : vec4<f32>;

// codes
fn interleavedGradientNoise ( position : vec2<f32> ) -> f32 {

	


	return fract( ( 52.9829189 * fract( dot( position, vec2<f32>( 0.06711056, 0.00583715 ) ) ) ) );

}

fn vogelDiskSample ( sampleIndex : i32, samplesCount : i32, phi : f32 ) -> vec2<f32> {

	var nodeVar0 : f32;

	nodeVar0 = ( ( f32( sampleIndex ) * 2.399963229728653 ) + phi );

	return ( vec2<f32>( cos( nodeVar0 ), sin( nodeVar0 ) ) * vec2<f32>( sqrt( ( ( f32( sampleIndex ) + 0.5 ) / f32( samplesCount ) ) ) ) );

}

fn V_GGX_SmithCorrelated ( alpha : f32, dotNL : f32, dotNV : f32 ) -> f32 {

	var nodeVar0 : f32;

	nodeVar0 = ( alpha * alpha );

	return ( 0.5 / max( ( ( dotNL * sqrt( ( nodeVar0 + ( ( 1.0 - nodeVar0 ) * ( dotNV * dotNV ) ) ) ) ) + ( dotNV * sqrt( ( nodeVar0 + ( ( 1.0 - nodeVar0 ) * ( dotNL * dotNL ) ) ) ) ) ), 0.000001 ) );

}

fn D_GGX ( alpha : f32, dotNH : f32 ) -> f32 {

	var nodeVar0 : f32;
	var nodeVar1 : f32;

	nodeVar0 = ( alpha * alpha );
	nodeVar1 = ( 1.0 - ( ( dotNH * dotNH ) * ( 1.0 - nodeVar0 ) ) );

	return ( ( nodeVar0 / ( nodeVar1 * nodeVar1 ) ) * 0.3183098861837907 );

}

fn roughnessToMip ( roughness : f32 ) -> f32 {

	var nodeVar0 : f32;

	nodeVar0 = 0.0;

	if ( ( roughness >= 0.8 ) ) {

		nodeVar0 = ( ( ( ( 1.0 - roughness ) * ( -1.0 - -2.0 ) ) / ( 1.0 - 0.8 ) ) + -2.0 );
		

	} else {


		if ( ( roughness >= 0.4 ) ) {

			nodeVar0 = ( ( ( ( 0.8 - roughness ) * ( 2.0 - -1.0 ) ) / ( 0.8 - 0.4 ) ) + -1.0 );
			

		} else {


			if ( ( roughness >= 0.305 ) ) {

				nodeVar0 = ( ( ( ( 0.4 - roughness ) * ( 3.0 - 2.0 ) ) / ( 0.4 - 0.305 ) ) + 2.0 );
				

			} else {


				if ( ( roughness >= 0.21 ) ) {

					nodeVar0 = ( ( ( ( 0.305 - roughness ) * ( 4.0 - 3.0 ) ) / ( 0.305 - 0.21 ) ) + 3.0 );
					

				} else {

					nodeVar0 = ( -2.0 * log2( ( 1.16 * roughness ) ) );
					

				}

				

			}

			

		}

		

	}


	return nodeVar0;

}

fn getFace ( direction : vec3<f32> ) -> f32 {

	var nodeVar0 : vec3<f32>;
	var nodeVar1 : f32;
	var nodeVar2 : f32;
	var nodeVar3 : f32;
	var nodeVar4 : f32;
	var nodeVar5 : f32;

	nodeVar0 = abs( direction );
	nodeVar1 = -1.0;

	if ( ( nodeVar0.x > nodeVar0.z ) ) {


		if ( ( nodeVar0.x > nodeVar0.y ) ) {


			if ( ( direction.x > 0.0 ) ) {

				nodeVar2 = 0.0;

			} else {

				nodeVar2 = 3.0;

			}

			nodeVar1 = nodeVar2;
			

		} else {


			if ( ( direction.y > 0.0 ) ) {

				nodeVar3 = 1.0;

			} else {

				nodeVar3 = 4.0;

			}

			nodeVar1 = nodeVar3;
			

		}

		

	} else {


		if ( ( nodeVar0.z > nodeVar0.y ) ) {


			if ( ( direction.z > 0.0 ) ) {

				nodeVar4 = 2.0;

			} else {

				nodeVar4 = 5.0;

			}

			nodeVar1 = nodeVar4;
			

		} else {


			if ( ( direction.y > 0.0 ) ) {

				nodeVar5 = 1.0;

			} else {

				nodeVar5 = 4.0;

			}

			nodeVar1 = nodeVar5;
			

		}

		

	}


	return nodeVar1;

}

fn getUV ( direction : vec3<f32>, face : f32 ) -> vec2<f32> {

	var nodeVar0 : vec2<f32>;

	nodeVar0 = vec2<f32>( 0.0, 0.0 );

	if ( ( face == 0.0 ) ) {

		nodeVar0 = ( vec2<f32>( direction.z, direction.y ) / vec2<f32>( abs( direction.x ) ) );
		

	} else {


		if ( ( face == 1.0 ) ) {

			nodeVar0 = ( vec2<f32>( ( - direction.x ), ( - direction.z ) ) / vec2<f32>( abs( direction.y ) ) );
			

		} else {


			if ( ( face == 2.0 ) ) {

				nodeVar0 = ( vec2<f32>( ( - direction.x ), direction.y ) / vec2<f32>( abs( direction.z ) ) );
				

			} else {


				if ( ( face == 3.0 ) ) {

					nodeVar0 = ( vec2<f32>( ( - direction.z ), direction.y ) / vec2<f32>( abs( direction.x ) ) );
					

				} else {


					if ( ( face == 4.0 ) ) {

						nodeVar0 = ( vec2<f32>( ( - direction.x ), direction.z ) / vec2<f32>( abs( direction.y ) ) );
						

					} else {

						nodeVar0 = ( vec2<f32>( direction.x, direction.y ) / vec2<f32>( abs( direction.z ) ) );
						

					}

					

				}

				

			}

			

		}

		

	}


	return ( vec2<f32>( 0.5 ) * ( nodeVar0 + vec2<f32>( 1.0 ) ) );

}



@fragment
fn main( @location( 0 ) v_positionView : vec3<f32>,
	@location( 1 ) v_normalViewGeometry : vec3<f32>,
	@location( 2 ) v_positionViewDirection : vec3<f32>,
	@location( 3 ) v_positionWorld : vec3<f32>,
	@location( 4 ) nodeVarying7 : vec2<f32>,
	@builtin( front_facing ) isFront : bool,
	@builtin( position ) fragCoord : vec4<f32> ) -> OutputStruct {

	// flow
	// code

	nodeVar0 = textureSample( nodeUniform2, nodeUniform2_sampler, ( object.nodeUniform3 * vec3<f32>( nodeVarying7, 1.0 ) ).xy );
	DiffuseColor = ( vec4<f32>( object.nodeUniform1, 1.0 ) * nodeVar0 );
	DiffuseColor.w = ( DiffuseColor.w * object.nodeUniform4 );
	DiffuseColor.w = smoothstep( object.nodeUniform5, ( object.nodeUniform5 + fwidth( DiffuseColor.w ) ), DiffuseColor.w );

	if ( ( DiffuseColor.w <= 0.0 ) ) {

		discard;
		

	}

	Metalness = object.nodeUniform6;
	normalViewGeometry = normalize( v_normalViewGeometry );
	nodeVar1 = max( abs( dpdx( normalViewGeometry ) ), abs( - dpdy( normalViewGeometry ) ) );
	Roughness = min( ( max( object.nodeUniform7, 0.0525 ) + max( max( nodeVar1.x, nodeVar1.y ), nodeVar1.z ) ), 1.0 );
	IOR = object.nodeUniform10;
	nodeVar2 = ( ( IOR - 1.0 ) / ( IOR + 1.0 ) );
	SpecularColor = ( min( ( vec3<f32>( ( nodeVar2 * nodeVar2 ) ) * object.nodeUniform11 ), vec3<f32>( 1.0, 1.0, 1.0 ) ) * vec3<f32>( object.nodeUniform12 ) );
	SpecularColorBlended = mix( SpecularColor, DiffuseColor.xyz, Metalness );
	SpecularF90 = mix( object.nodeUniform12, 1.0, Metalness );
	DiffuseContribution = ( DiffuseColor.xyz * vec3<f32>( ( 1.0 - object.nodeUniform6 ) ) );
	EmissiveColor = ( object.nodeUniform13 * vec3<f32>( object.nodeUniform14 ) );
	irradiance = vec3<f32>( 0.0, 0.0, 0.0 );
	NORMAL_normalView = ( normalViewGeometry * vec3<f32>( ( ( f32( isFront ) * 2.0 ) - 1.0 ) ) );
	normalView = NORMAL_normalView;
	nodeVar3 = vec4<f32>( normalView, 0.0 );
	nodeVar4 = ( nodeVar3 * render.cameraViewMatrix );
	nodeVar5 = normalize( nodeVar4.xyz );
	normalWorld = nodeVar5;
	nodeVar6 = dot( normalWorld, normalize( render.nodeUniform18 ) );
	nodeVar7 = ( nodeVar6 * 0.5 );
	nodeVar8 = ( nodeVar7 + 0.5 );
	nodeVar9 = mix( render.nodeUniform15, render.nodeUniform16, nodeVar8 );
	nodeVar10 = ( irradiance + nodeVar9 );
	irradiance = nodeVar10;
	directDiffuse = vec3<f32>( 0.0, 0.0, 0.0 );
	positionViewDirection = normalize( v_positionViewDirection );
	nodeVar11 = ( render.nodeUniform20 - render.nodeUniform21 );
	nodeVar12 = vec4<f32>( nodeVar11, 0.0 );
	nodeVar13 = ( render.cameraViewMatrix * nodeVar12 );
	nodeVar14 = normalize( nodeVar13.xyz );
	nodeVar15 = nodeVar14;
	nodeVar16 = ( normalView * vec3<f32>( 0.12 ) );
	nodeVar17 = ( nodeVar15 + nodeVar16 );
	nodeVar18 = normalize( nodeVar17 );
	nodeVar19 = ( - nodeVar18 );
	nodeVar20 = dot( positionViewDirection, nodeVar19 );
	nodeVar21 = pow( clamp( nodeVar20, 0.0, 1.0 ), 3.0 );
	nodeVar22 = ( nodeVar21 * 0.8 );
	nodeVar23 = ( nodeVar22 + 0.0 );
	nodeVar24 = ( vec3<f32>( nodeVar23 ) * vec3<f32>( 0.18, 0.23, 0.065 ) );
	shadowPositionWorld = v_positionWorld;
	nodeVar26 = ( render.nodeUniform23 * vec4<f32>( ( shadowPositionWorld + ( normalWorld * vec3<f32>( render.nodeUniform24 ) ) ), 1.0 ) );
	nodeVar27 = ( nodeVar26.xyz / vec3<f32>( nodeVar26.w ) );
	nodeVar28 = vec3<f32>( nodeVar27.x, ( 1.0 - nodeVar27.y ), ( nodeVar27.z + render.nodeUniform25 ) );

	if ( ( ( ( ( ( nodeVar28.x >= 0.0 ) && ( nodeVar28.x <= 1.0 ) ) && ( nodeVar28.y >= 0.0 ) ) && ( nodeVar28.y <= 1.0 ) ) && ( nodeVar28.z <= 1.0 ) ) ) {

		nodeVar29 = ( interleavedGradientNoise( fragCoord.xy ) * 6.28318530718 );
		nodeVar30 = ( render.nodeUniform27 * ( vec2<f32>( 1.0, 1.0 ) / render.nodeUniform28 ).x );
		nodeVar31 = ( nodeVar28.xy + ( vogelDiskSample( 0, 5, nodeVar29 ) * vec2<f32>( nodeVar30 ) ) );
		nodeVar32 = textureSampleCompare( nodeUniform26, nodeUniform26_sampler, nodeVar31, nodeVar28.z );
		nodeVar33 = ( nodeVar28.xy + ( vogelDiskSample( 1, 5, nodeVar29 ) * vec2<f32>( nodeVar30 ) ) );
		nodeVar34 = textureSampleCompare( nodeUniform26, nodeUniform26_sampler, nodeVar33, nodeVar28.z );
		nodeVar35 = ( nodeVar28.xy + ( vogelDiskSample( 2, 5, nodeVar29 ) * vec2<f32>( nodeVar30 ) ) );
		nodeVar36 = textureSampleCompare( nodeUniform26, nodeUniform26_sampler, nodeVar35, nodeVar28.z );
		nodeVar37 = ( nodeVar28.xy + ( vogelDiskSample( 3, 5, nodeVar29 ) * vec2<f32>( nodeVar30 ) ) );
		nodeVar38 = textureSampleCompare( nodeUniform26, nodeUniform26_sampler, nodeVar37, nodeVar28.z );
		nodeVar39 = ( nodeVar28.xy + ( vogelDiskSample( 4, 5, nodeVar29 ) * vec2<f32>( nodeVar30 ) ) );
		nodeVar40 = textureSampleCompare( nodeUniform26, nodeUniform26_sampler, nodeVar39, nodeVar28.z );
		nodeVar25 = ( ( ( ( ( nodeVar32 + nodeVar34 ) + nodeVar36 ) + nodeVar38 ) + nodeVar40 ) * 0.2 );

	} else {

		nodeVar25 = 1.0;

	}

	nodeVar41 = mix( 1.0, nodeVar25, render.nodeUniform29 );
	nodeVar42 = ( render.nodeUniform22 * vec3<f32>( nodeVar41 ) );
	nodeVar43 = ( vec3<f32>( 0.45 ) * nodeVar42 );
	nodeVar44 = ( nodeVar24 * nodeVar43 );
	nodeVar45 = ( directDiffuse + nodeVar44 );
	directDiffuse = nodeVar45;
	nodeVar46 = dot( normalView, nodeVar15 );
	nodeVar47 = ( vec3<f32>( clamp( nodeVar46, 0.0, 1.0 ) ) * nodeVar42 );
	nodeVar48 = nodeVar47;
	nodeVar49 = ( DiffuseContribution * vec3<f32>( 0.3183098861837907 ) );
	nodeVar50 = ( nodeVar48 * nodeVar49 );
	nodeVar51 = ( directDiffuse + nodeVar50 );
	directDiffuse = nodeVar51;
	directSpecular = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar52 = normalize( ( nodeVar15 + positionViewDirection ) );
	nodeVar53 = clamp( dot( positionViewDirection, nodeVar52 ), 0.0, 1.0 );
	nodeVar54 = exp2( ( ( ( nodeVar53 * -5.55473 ) - 6.98316 ) * nodeVar53 ) );
	nodeVar55 = ( Roughness * Roughness );
	nodeVar56 = textureSample( nodeUniform30, nodeUniform30_sampler, vec2<f32>( Roughness, clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) );
	nodeVar57 = textureSample( nodeUniform30, nodeUniform30_sampler, vec2<f32>( Roughness, clamp( dot( normalView, nodeVar15 ), 0.0, 1.0 ) ) );
	nodeVar58 = ( SpecularColorBlended + ( ( vec3<f32>( 1.0 ) - SpecularColorBlended ) * vec3<f32>( 0.047619 ) ) );
	nodeVar59 = ( 1.0 - ( nodeVar56.xy.x + nodeVar56.xy.y ) );
	nodeVar60 = ( 1.0 - ( nodeVar57.xy.x + nodeVar57.xy.y ) );
	nodeVar61 = ( ( ( ( ( SpecularColorBlended * vec3<f32>( ( 1.0 - nodeVar54 ) ) ) + vec3<f32>( ( 1.0 * nodeVar54 ) ) ) * vec3<f32>( V_GGX_SmithCorrelated( nodeVar55, clamp( dot( normalView, nodeVar15 ), 0.0, 1.0 ), clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) ) ) * vec3<f32>( D_GGX( nodeVar55, clamp( dot( normalView, nodeVar52 ), 0.0, 1.0 ) ) ) ) + ( ( ( ( ( ( SpecularColorBlended * vec3<f32>( nodeVar56.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar56.xy.y ) ) ) * ( ( SpecularColorBlended * vec3<f32>( nodeVar57.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar57.xy.y ) ) ) ) * nodeVar58 ) / ( ( vec3<f32>( 1.0 ) - ( ( vec3<f32>( ( nodeVar59 * nodeVar60 ) ) * nodeVar58 ) * nodeVar58 ) ) + vec3<f32>( 0.000001 ) ) ) * vec3<f32>( ( nodeVar59 * nodeVar60 ) ) ) );
	nodeVar62 = ( nodeVar48 * nodeVar61 );
	nodeVar63 = ( directSpecular + nodeVar62 );
	directSpecular = nodeVar63;
	nodeVar64 = ( render.nodeUniform31 - render.nodeUniform32 );
	nodeVar65 = vec4<f32>( nodeVar64, 0.0 );
	nodeVar66 = ( render.cameraViewMatrix * nodeVar65 );
	nodeVar67 = normalize( nodeVar66.xyz );
	nodeVar68 = nodeVar67;
	nodeVar69 = ( normalView * vec3<f32>( 0.12 ) );
	nodeVar70 = ( nodeVar68 + nodeVar69 );
	nodeVar71 = normalize( nodeVar70 );
	nodeVar72 = ( - nodeVar71 );
	nodeVar73 = dot( positionViewDirection, nodeVar72 );
	nodeVar74 = pow( clamp( nodeVar73, 0.0, 1.0 ), 3.0 );
	nodeVar75 = ( nodeVar74 * 0.8 );
	nodeVar76 = ( nodeVar75 + 0.0 );
	nodeVar77 = ( vec3<f32>( nodeVar76 ) * vec3<f32>( 0.18, 0.23, 0.065 ) );
	nodeVar78 = ( vec3<f32>( 0.45 ) * render.nodeUniform33 );
	nodeVar79 = ( nodeVar77 * nodeVar78 );
	nodeVar80 = ( directDiffuse + nodeVar79 );
	directDiffuse = nodeVar80;
	nodeVar81 = dot( normalView, nodeVar68 );
	nodeVar82 = ( vec3<f32>( clamp( nodeVar81, 0.0, 1.0 ) ) * render.nodeUniform33 );
	nodeVar83 = nodeVar82;
	nodeVar84 = ( DiffuseContribution * vec3<f32>( 0.3183098861837907 ) );
	nodeVar85 = ( nodeVar83 * nodeVar84 );
	nodeVar86 = ( directDiffuse + nodeVar85 );
	directDiffuse = nodeVar86;
	nodeVar87 = normalize( ( nodeVar68 + positionViewDirection ) );
	nodeVar88 = clamp( dot( positionViewDirection, nodeVar87 ), 0.0, 1.0 );
	nodeVar89 = exp2( ( ( ( nodeVar88 * -5.55473 ) - 6.98316 ) * nodeVar88 ) );
	nodeVar90 = ( Roughness * Roughness );
	nodeVar91 = textureSample( nodeUniform30, nodeUniform30_sampler, vec2<f32>( Roughness, clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) );
	nodeVar92 = textureSample( nodeUniform30, nodeUniform30_sampler, vec2<f32>( Roughness, clamp( dot( normalView, nodeVar68 ), 0.0, 1.0 ) ) );
	nodeVar93 = ( SpecularColorBlended + ( ( vec3<f32>( 1.0 ) - SpecularColorBlended ) * vec3<f32>( 0.047619 ) ) );
	nodeVar94 = ( 1.0 - ( nodeVar91.xy.x + nodeVar91.xy.y ) );
	nodeVar95 = ( 1.0 - ( nodeVar92.xy.x + nodeVar92.xy.y ) );
	nodeVar96 = ( ( ( ( ( SpecularColorBlended * vec3<f32>( ( 1.0 - nodeVar89 ) ) ) + vec3<f32>( ( 1.0 * nodeVar89 ) ) ) * vec3<f32>( V_GGX_SmithCorrelated( nodeVar90, clamp( dot( normalView, nodeVar68 ), 0.0, 1.0 ), clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) ) ) * vec3<f32>( D_GGX( nodeVar90, clamp( dot( normalView, nodeVar87 ), 0.0, 1.0 ) ) ) ) + ( ( ( ( ( ( SpecularColorBlended * vec3<f32>( nodeVar91.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar91.xy.y ) ) ) * ( ( SpecularColorBlended * vec3<f32>( nodeVar92.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar92.xy.y ) ) ) ) * nodeVar93 ) / ( ( vec3<f32>( 1.0 ) - ( ( vec3<f32>( ( nodeVar94 * nodeVar95 ) ) * nodeVar93 ) * nodeVar93 ) ) + vec3<f32>( 0.000001 ) ) ) * vec3<f32>( ( nodeVar94 * nodeVar95 ) ) ) );
	nodeVar97 = ( nodeVar83 * nodeVar96 );
	nodeVar98 = ( directSpecular + nodeVar97 );
	directSpecular = nodeVar98;
	radiance = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar99 = clamp( roughnessToMip( Roughness ), -2.0, object.nodeUniform34 );
	nodeVar100 = floor( nodeVar99 );
	nodeVar101 = nodeVar100;
	nodeVar102 = normalize( ( vec4<f32>( normalize( mix( reflect( ( - positionViewDirection ), normalView ), normalView, ( ( ( Roughness * Roughness ) * Roughness ) * Roughness ) ) ), 0.0 ) * render.cameraViewMatrix ).xyz );
	nodeVar103 = getFace( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( nodeVar102.x, ( - nodeVar102.y ), nodeVar102.z ), 1.0 ) ).xyz );
	nodeVar104 = max( ( 4.0 - nodeVar101 ), 0.0 );
	nodeVar101 = max( nodeVar101, 4.0 );
	nodeVar105 = exp2( nodeVar101 );
	nodeVar106 = ( ( getUV( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( nodeVar102.x, ( - nodeVar102.y ), nodeVar102.z ), 1.0 ) ).xyz, nodeVar103 ) * vec2<f32>( ( nodeVar105 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

	if ( ( nodeVar103 > 2.0 ) ) {

		nodeVar106.y = ( nodeVar106.y + nodeVar105 );
		nodeVar103 = ( nodeVar103 - 3.0 );
		

	}

	nodeVar106.x = ( nodeVar106.x + ( nodeVar103 * nodeVar105 ) );
	nodeVar106.x = ( nodeVar106.x + ( nodeVar104 * ( 3.0 * 16.0 ) ) );
	nodeVar106.y = ( nodeVar106.y + ( 4.0 * ( exp2( object.nodeUniform34 ) - nodeVar105 ) ) );
	nodeVar106.x = ( nodeVar106.x * object.nodeUniform36 );
	nodeVar106.y = ( nodeVar106.y * object.nodeUniform37 );
	nodeVar107 = textureSampleGrad( nodeUniform38, nodeUniform38_sampler, nodeVar106, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
	nodeVar108 = nodeVar107.xyz;
	nodeVar109 = fract( nodeVar99 );

	if ( ( nodeVar109 != 0.0 ) ) {

		nodeVar110 = ( nodeVar100 + 1.0 );
		nodeVar111 = getFace( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( nodeVar102.x, ( - nodeVar102.y ), nodeVar102.z ), 1.0 ) ).xyz );
		nodeVar112 = max( ( 4.0 - nodeVar110 ), 0.0 );
		nodeVar110 = max( nodeVar110, 4.0 );
		nodeVar113 = exp2( nodeVar110 );
		nodeVar114 = ( ( getUV( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( nodeVar102.x, ( - nodeVar102.y ), nodeVar102.z ), 1.0 ) ).xyz, nodeVar111 ) * vec2<f32>( ( nodeVar113 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

		if ( ( nodeVar111 > 2.0 ) ) {

			nodeVar114.y = ( nodeVar114.y + nodeVar113 );
			nodeVar111 = ( nodeVar111 - 3.0 );
			

		}

		nodeVar114.x = ( nodeVar114.x + ( nodeVar111 * nodeVar113 ) );
		nodeVar114.x = ( nodeVar114.x + ( nodeVar112 * ( 3.0 * 16.0 ) ) );
		nodeVar114.y = ( nodeVar114.y + ( 4.0 * ( exp2( object.nodeUniform34 ) - nodeVar113 ) ) );
		nodeVar114.x = ( nodeVar114.x * object.nodeUniform36 );
		nodeVar114.y = ( nodeVar114.y * object.nodeUniform37 );
		nodeVar115 = textureSampleGrad( nodeUniform38, nodeUniform38_sampler, nodeVar114, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
		nodeVar116 = nodeVar115.xyz;
		nodeVar108 = mix( nodeVar108, nodeVar116, nodeVar109 );
		

	}

	nodeVar117 = ( radiance + ( nodeVar108 * vec3<f32>( object.nodeUniform39 ) ) );
	radiance = nodeVar117;
	iblIrradiance = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar118 = clamp( roughnessToMip( 1.0 ), -2.0, object.nodeUniform34 );
	nodeVar119 = floor( nodeVar118 );
	nodeVar120 = nodeVar119;
	nodeVar121 = getFace( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz );
	nodeVar122 = max( ( 4.0 - nodeVar120 ), 0.0 );
	nodeVar120 = max( nodeVar120, 4.0 );
	nodeVar123 = exp2( nodeVar120 );
	nodeVar124 = ( ( getUV( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz, nodeVar121 ) * vec2<f32>( ( nodeVar123 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

	if ( ( nodeVar121 > 2.0 ) ) {

		nodeVar124.y = ( nodeVar124.y + nodeVar123 );
		nodeVar121 = ( nodeVar121 - 3.0 );
		

	}

	nodeVar124.x = ( nodeVar124.x + ( nodeVar121 * nodeVar123 ) );
	nodeVar124.x = ( nodeVar124.x + ( nodeVar122 * ( 3.0 * 16.0 ) ) );
	nodeVar124.y = ( nodeVar124.y + ( 4.0 * ( exp2( object.nodeUniform34 ) - nodeVar123 ) ) );
	nodeVar124.x = ( nodeVar124.x * object.nodeUniform36 );
	nodeVar124.y = ( nodeVar124.y * object.nodeUniform37 );
	nodeVar125 = textureSampleGrad( nodeUniform38, nodeUniform38_sampler, nodeVar124, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
	nodeVar126 = nodeVar125.xyz;
	nodeVar127 = fract( nodeVar118 );

	if ( ( nodeVar127 != 0.0 ) ) {

		nodeVar128 = ( nodeVar119 + 1.0 );
		nodeVar129 = getFace( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz );
		nodeVar130 = max( ( 4.0 - nodeVar128 ), 0.0 );
		nodeVar128 = max( nodeVar128, 4.0 );
		nodeVar131 = exp2( nodeVar128 );
		nodeVar132 = ( ( getUV( ( object.nodeUniform35 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz, nodeVar129 ) * vec2<f32>( ( nodeVar131 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

		if ( ( nodeVar129 > 2.0 ) ) {

			nodeVar132.y = ( nodeVar132.y + nodeVar131 );
			nodeVar129 = ( nodeVar129 - 3.0 );
			

		}

		nodeVar132.x = ( nodeVar132.x + ( nodeVar129 * nodeVar131 ) );
		nodeVar132.x = ( nodeVar132.x + ( nodeVar130 * ( 3.0 * 16.0 ) ) );
		nodeVar132.y = ( nodeVar132.y + ( 4.0 * ( exp2( object.nodeUniform34 ) - nodeVar131 ) ) );
		nodeVar132.x = ( nodeVar132.x * object.nodeUniform36 );
		nodeVar132.y = ( nodeVar132.y * object.nodeUniform37 );
		nodeVar133 = textureSampleGrad( nodeUniform38, nodeUniform38_sampler, nodeVar132, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
		nodeVar134 = nodeVar133.xyz;
		nodeVar126 = mix( nodeVar126, nodeVar134, nodeVar127 );
		

	}

	nodeVar135 = ( iblIrradiance + ( ( nodeVar126 * vec3<f32>( 3.141592653589793 ) ) * vec3<f32>( object.nodeUniform39 ) ) );
	iblIrradiance = nodeVar135;
	nodeVar136 = ( DiffuseContribution * vec3<f32>( 0.3183098861837907 ) );
	nodeVar137 = ( irradiance * nodeVar136 );
	nodeVar138 = nodeVar137;
	indirectDiffuse = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar139 = ( indirectDiffuse + nodeVar138 );
	indirectDiffuse = nodeVar139;
	singleScatteringDielectric = vec3<f32>( 0.0, 0.0, 0.0 );
	multiScatteringDielectric = vec3<f32>( 0.0, 0.0, 0.0 );
	singleScatteringMetallic = vec3<f32>( 0.0, 0.0, 0.0 );
	multiScatteringMetallic = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar140 = dot( normalView, positionViewDirection );
	nodeVar141 = textureSample( nodeUniform30, nodeUniform30_sampler, vec2<f32>( Roughness, clamp( nodeVar140, 0.0, 1.0 ) ) );
	nodeVar142 = ( SpecularColor * vec3<f32>( nodeVar141.xy.x ) );
	nodeVar143 = ( SpecularF90 * nodeVar141.xy.y );
	nodeVar144 = ( nodeVar142 + vec3<f32>( nodeVar143 ) );
	nodeVar145 = ( singleScatteringDielectric + nodeVar144 );
	singleScatteringDielectric = nodeVar145;
	nodeVar146 = ( vec3<f32>( 1.0 ) - SpecularColor );
	nodeVar147 = nodeVar146;
	nodeVar148 = ( nodeVar147 * vec3<f32>( 0.047619 ) );
	nodeVar149 = ( SpecularColor + nodeVar148 );
	nodeVar150 = ( nodeVar144 * nodeVar149 );
	nodeVar151 = ( nodeVar141.xy.x + nodeVar141.xy.y );
	nodeVar152 = ( 1.0 - nodeVar151 );
	nodeVar153 = nodeVar152;
	nodeVar154 = ( vec3<f32>( nodeVar153 ) * nodeVar149 );
	nodeVar155 = ( vec3<f32>( 1.0 ) - nodeVar154 );
	nodeVar156 = nodeVar155;
	nodeVar157 = ( nodeVar150 / nodeVar156 );
	nodeVar158 = ( nodeVar157 * vec3<f32>( nodeVar153 ) );
	nodeVar159 = ( multiScatteringDielectric + nodeVar158 );
	multiScatteringDielectric = nodeVar159;
	nodeVar160 = dot( normalView, positionViewDirection );
	nodeVar161 = textureSample( nodeUniform30, nodeUniform30_sampler, vec2<f32>( Roughness, clamp( nodeVar160, 0.0, 1.0 ) ) );
	nodeVar162 = ( DiffuseColor.xyz * vec3<f32>( nodeVar161.xy.x ) );
	nodeVar163 = ( SpecularF90 * nodeVar161.xy.y );
	nodeVar164 = ( nodeVar162 + vec3<f32>( nodeVar163 ) );
	nodeVar165 = ( singleScatteringMetallic + nodeVar164 );
	singleScatteringMetallic = nodeVar165;
	nodeVar166 = ( vec3<f32>( 1.0 ) - DiffuseColor.xyz );
	nodeVar167 = nodeVar166;
	nodeVar168 = ( nodeVar167 * vec3<f32>( 0.047619 ) );
	nodeVar169 = ( DiffuseColor.xyz + nodeVar168 );
	nodeVar170 = ( nodeVar164 * nodeVar169 );
	nodeVar171 = ( nodeVar161.xy.x + nodeVar161.xy.y );
	nodeVar172 = ( 1.0 - nodeVar171 );
	nodeVar173 = nodeVar172;
	nodeVar174 = ( vec3<f32>( nodeVar173 ) * nodeVar169 );
	nodeVar175 = ( vec3<f32>( 1.0 ) - nodeVar174 );
	nodeVar176 = nodeVar175;
	nodeVar177 = ( nodeVar170 / nodeVar176 );
	nodeVar178 = ( nodeVar177 * vec3<f32>( nodeVar173 ) );
	nodeVar179 = ( multiScatteringMetallic + nodeVar178 );
	multiScatteringMetallic = nodeVar179;
	nodeVar180 = mix( singleScatteringDielectric, singleScatteringMetallic, Metalness );
	nodeVar181 = ( radiance * nodeVar180 );
	nodeVar182 = mix( multiScatteringDielectric, multiScatteringMetallic, Metalness );
	nodeVar183 = ( iblIrradiance * vec3<f32>( 0.3183098861837907 ) );
	nodeVar184 = ( nodeVar182 * nodeVar183 );
	nodeVar185 = ( nodeVar181 + nodeVar184 );
	nodeVar186 = nodeVar185;
	nodeVar187 = ( singleScatteringDielectric + multiScatteringDielectric );
	nodeVar188 = ( vec3<f32>( 1.0 ) - nodeVar187 );
	nodeVar189 = nodeVar188;
	nodeVar190 = ( DiffuseContribution * nodeVar189 );
	nodeVar191 = ( nodeVar190 * nodeVar183 );
	nodeVar192 = nodeVar191;
	indirectSpecular = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar193 = ( indirectSpecular + nodeVar186 );
	indirectSpecular = nodeVar193;
	nodeVar194 = ( indirectDiffuse + nodeVar192 );
	indirectDiffuse = nodeVar194;
	ambientOcclusion = 1.0;
	nodeVar195 = ( indirectDiffuse * vec3<f32>( ambientOcclusion ) );
	indirectDiffuse = nodeVar195;
	nodeVar196 = dot( normalView, positionViewDirection );
	nodeVar197 = ( clamp( nodeVar196, 0.0, 1.0 ) + ambientOcclusion );
	nodeVar198 = ( Roughness * -16.0 );
	nodeVar199 = ( 1.0 - nodeVar198 );
	nodeVar200 = nodeVar199;
	nodeVar201 = ( - nodeVar200 );
	nodeVar202 = exp2( nodeVar201 );
	nodeVar203 = pow( nodeVar197, nodeVar202 );
	nodeVar204 = ( 1.0 - nodeVar203 );
	nodeVar205 = nodeVar204;
	nodeVar206 = ( ambientOcclusion - nodeVar205 );
	nodeVar207 = ( indirectSpecular * vec3<f32>( clamp( nodeVar206, 0.0, 1.0 ) ) );
	indirectSpecular = nodeVar207;
	nodeVar208 = ( directDiffuse + indirectDiffuse );
	totalDiffuse = nodeVar208;
	nodeVar209 = ( directSpecular + indirectSpecular );
	totalSpecular = nodeVar209;
	nodeVar210 = ( totalDiffuse + totalSpecular );
	outgoingLight = nodeVar210;
	Output = max( vec4<f32>( ( outgoingLight + EmissiveColor ), DiffuseColor.w ), vec4<f32>( 0.0 ) );
	nodeVar211 = ( - v_positionView.z );
	nodeVar212 = vec4<f32>( mix( Output.xyz, render.nodeUniform40, ( 1.0 - exp( ( - ( ( ( render.nodeUniform41 * render.nodeUniform41 ) * nodeVar211 ) * nodeVar211 ) ) ) ) ), Output.w );
	Output = nodeVar212;

	// result

	output.color = nodeVar212;

	return output;

}
