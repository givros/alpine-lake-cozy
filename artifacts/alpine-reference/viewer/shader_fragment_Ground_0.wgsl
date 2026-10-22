// Three.js r184 - Node System

// global
diagnostic( off, derivative_uniformity );


// structs

struct OutputStruct {
	@location( 0 ) color: vec4<f32>
};
var<private> output : OutputStruct;

// uniforms
@binding( 0 ) @group( 1 ) var nodeUniform0_sampler : sampler;
@binding( 1 ) @group( 1 ) var nodeUniform0 : texture_2d<f32>;
@binding( 2 ) @group( 1 ) var nodeUniform1_sampler : sampler;
@binding( 3 ) @group( 1 ) var nodeUniform1 : texture_2d<f32>;
@binding( 4 ) @group( 1 ) var nodeUniform2_sampler : sampler;
@binding( 5 ) @group( 1 ) var nodeUniform2 : texture_2d<f32>;
@binding( 6 ) @group( 1 ) var nodeUniform3_sampler : sampler;
@binding( 7 ) @group( 1 ) var nodeUniform3 : texture_2d<f32>;
@binding( 8 ) @group( 1 ) var nodeUniform4_sampler : sampler;
@binding( 9 ) @group( 1 ) var nodeUniform4 : texture_2d<f32>;
@binding( 11 ) @group( 1 ) var nodeUniform7_sampler : sampler;
@binding( 12 ) @group( 1 ) var nodeUniform7 : texture_2d<f32>;
@binding( 13 ) @group( 1 ) var nodeUniform8_sampler : sampler;
@binding( 14 ) @group( 1 ) var nodeUniform8 : texture_2d<f32>;
@binding( 15 ) @group( 1 ) var nodeUniform9_sampler : sampler;
@binding( 16 ) @group( 1 ) var nodeUniform9 : texture_2d<f32>;
@binding( 17 ) @group( 1 ) var nodeUniform10_sampler : sampler;
@binding( 18 ) @group( 1 ) var nodeUniform10 : texture_2d<f32>;
@binding( 19 ) @group( 1 ) var nodeUniform11_sampler : sampler;
@binding( 20 ) @group( 1 ) var nodeUniform11 : texture_2d<f32>;
@binding( 21 ) @group( 1 ) var nodeUniform27_sampler : sampler_comparison;
@binding( 22 ) @group( 1 ) var nodeUniform27 : texture_depth_2d;
@binding( 23 ) @group( 1 ) var nodeUniform31_sampler : sampler;
@binding( 24 ) @group( 1 ) var nodeUniform31 : texture_2d<f32>;
@binding( 25 ) @group( 1 ) var nodeUniform39_sampler : sampler;
@binding( 26 ) @group( 1 ) var nodeUniform39 : texture_2d<f32>;

struct objectStruct {
	nodeUniform5 : f32,
	nodeUniform6 : f32,
	nodeUniform13 : mat3x3<f32>,
	nodeUniform14 : vec3<f32>,
	nodeUniform15 : f32,
	nodeUniform18 : mat4x4<f32>,
	nodeUniform35 : f32,
	nodeUniform36 : mat4x4<f32>,
	nodeUniform37 : f32,
	nodeUniform38 : f32,
	nodeUniform40 : f32
};
@binding( 10 ) @group( 1 )
var<uniform> object : objectStruct;

struct renderStruct {
	cameraProjectionMatrix : mat4x4<f32>,
	cameraViewMatrix : mat4x4<f32>,
	nodeUniform17 : vec3<f32>,
	nodeUniform20 : vec3<f32>,
	nodeUniform16 : vec3<f32>,
	nodeUniform23 : vec3<f32>,
	nodeUniform34 : vec3<f32>,
	nodeUniform21 : vec3<f32>,
	nodeUniform22 : vec3<f32>,
	nodeUniform32 : vec3<f32>,
	nodeUniform33 : vec3<f32>,
	nodeUniform24 : mat4x4<f32>,
	nodeUniform25 : f32,
	nodeUniform26 : f32,
	nodeUniform30 : f32,
	nodeUniform41 : vec3<f32>,
	nodeUniform42 : f32,
	nodeUniform28 : f32,
	nodeUniform29 : vec2<f32>
};
@binding( 0 ) @group( 0 )
var<uniform> render : renderStruct;

// vars
var<private> DiffuseColor : vec4<f32>;
var<private> nodeVar0 : vec4<f32>;
var<private> nodeVar1 : vec4<f32>;
var<private> nodeVar2 : vec4<f32>;
var<private> nodeVar3 : vec4<f32>;
var<private> nodeVar4 : vec4<f32>;
var<private> Metalness : f32;
var<private> Roughness : f32;
var<private> nodeVar5 : vec4<f32>;
var<private> nodeVar6 : vec4<f32>;
var<private> nodeVar7 : vec4<f32>;
var<private> nodeVar8 : vec4<f32>;
var<private> nodeVar9 : vec4<f32>;
var<private> normalViewGeometry : vec3<f32>;
var<private> nodeVar10 : vec3<f32>;
var<private> SpecularColor : vec3<f32>;
var<private> SpecularColorBlended : vec3<f32>;
var<private> SpecularF90 : f32;
var<private> DiffuseContribution : vec3<f32>;
var<private> EmissiveColor : vec3<f32>;
var<private> Output : vec4<f32>;
var<private> irradiance : vec3<f32>;
var<private> NORMAL_normalView : vec3<f32>;
var<private> nodeVar11 : vec3<f32>;
var<private> nodeVar12 : vec2<f32>;
var<private> nodeVar13 : vec3<f32>;
var<private> nodeVar14 : vec2<f32>;
var<private> nodeVar15 : vec3<f32>;
var<private> nodeVar16 : f32;
var<private> nodeVar17 : vec3<f32>;
var<private> nodeVar18 : f32;
var<private> tangentViewFrame : vec3<f32>;
var<private> NORMAL_tangentView : vec3<f32>;
var<private> bitangentViewFrame : vec3<f32>;
var<private> NORMAL_bitangentView : vec3<f32>;
var<private> NORMAL_TBNViewMatrix : mat3x3<f32>;
var<private> nodeVar19 : vec4<f32>;
var<private> nodeVar20 : vec4<f32>;
var<private> nodeVar21 : vec4<f32>;
var<private> nodeVar22 : vec4<f32>;
var<private> nodeVar23 : vec4<f32>;
var<private> nodeVar24 : vec3<f32>;
var<private> normalView : vec3<f32>;
var<private> nodeVar25 : vec4<f32>;
var<private> nodeVar26 : vec4<f32>;
var<private> nodeVar27 : vec3<f32>;
var<private> normalWorld : vec3<f32>;
var<private> nodeVar28 : f32;
var<private> nodeVar29 : f32;
var<private> nodeVar30 : f32;
var<private> nodeVar31 : vec3<f32>;
var<private> nodeVar32 : vec3<f32>;
var<private> nodeVar33 : vec3<f32>;
var<private> nodeVar34 : vec4<f32>;
var<private> nodeVar35 : vec4<f32>;
var<private> nodeVar36 : vec3<f32>;
var<private> nodeVar37 : vec3<f32>;
var<private> nodeVar38 : f32;
var<private> shadowPositionWorld : vec3<f32>;
var<private> nodeVar39 : f32;
var<private> nodeVar40 : vec4<f32>;
var<private> nodeVar41 : vec3<f32>;
var<private> nodeVar42 : vec3<f32>;
var<private> nodeVar43 : f32;
var<private> nodeVar44 : f32;
var<private> nodeVar45 : vec2<f32>;
var<private> nodeVar46 : f32;
var<private> nodeVar47 : vec2<f32>;
var<private> nodeVar48 : f32;
var<private> nodeVar49 : vec2<f32>;
var<private> nodeVar50 : f32;
var<private> nodeVar51 : vec2<f32>;
var<private> nodeVar52 : f32;
var<private> nodeVar53 : vec2<f32>;
var<private> nodeVar54 : f32;
var<private> nodeVar55 : f32;
var<private> nodeVar56 : vec3<f32>;
var<private> nodeVar57 : vec3<f32>;
var<private> directDiffuse : vec3<f32>;
var<private> nodeVar58 : vec3<f32>;
var<private> nodeVar59 : vec3<f32>;
var<private> nodeVar60 : vec3<f32>;
var<private> directSpecular : vec3<f32>;
var<private> positionViewDirection : vec3<f32>;
var<private> nodeVar61 : vec3<f32>;
var<private> nodeVar62 : f32;
var<private> nodeVar63 : f32;
var<private> nodeVar64 : f32;
var<private> nodeVar65 : vec4<f32>;
var<private> nodeVar66 : vec4<f32>;
var<private> nodeVar67 : vec3<f32>;
var<private> nodeVar68 : f32;
var<private> nodeVar69 : f32;
var<private> nodeVar70 : vec3<f32>;
var<private> nodeVar71 : vec3<f32>;
var<private> nodeVar72 : vec3<f32>;
var<private> nodeVar73 : vec3<f32>;
var<private> nodeVar74 : vec4<f32>;
var<private> nodeVar75 : vec4<f32>;
var<private> nodeVar76 : vec3<f32>;
var<private> nodeVar77 : vec3<f32>;
var<private> nodeVar78 : f32;
var<private> nodeVar79 : vec3<f32>;
var<private> nodeVar80 : vec3<f32>;
var<private> nodeVar81 : vec3<f32>;
var<private> nodeVar82 : vec3<f32>;
var<private> nodeVar83 : vec3<f32>;
var<private> nodeVar84 : vec3<f32>;
var<private> nodeVar85 : f32;
var<private> nodeVar86 : f32;
var<private> nodeVar87 : f32;
var<private> nodeVar88 : vec4<f32>;
var<private> nodeVar89 : vec4<f32>;
var<private> nodeVar90 : vec3<f32>;
var<private> nodeVar91 : f32;
var<private> nodeVar92 : f32;
var<private> nodeVar93 : vec3<f32>;
var<private> nodeVar94 : vec3<f32>;
var<private> nodeVar95 : vec3<f32>;
var<private> radiance : vec3<f32>;
var<private> nodeVar96 : f32;
var<private> nodeVar97 : f32;
var<private> nodeVar98 : f32;
var<private> nodeVar99 : vec3<f32>;
var<private> nodeVar100 : f32;
var<private> nodeVar101 : f32;
var<private> nodeVar102 : f32;
var<private> nodeVar103 : vec2<f32>;
var<private> nodeVar104 : vec4<f32>;
var<private> nodeVar105 : vec3<f32>;
var<private> nodeVar106 : f32;
var<private> nodeVar107 : f32;
var<private> nodeVar108 : f32;
var<private> nodeVar109 : f32;
var<private> nodeVar110 : f32;
var<private> nodeVar111 : vec2<f32>;
var<private> nodeVar112 : vec4<f32>;
var<private> nodeVar113 : vec3<f32>;
var<private> nodeVar114 : vec3<f32>;
var<private> iblIrradiance : vec3<f32>;
var<private> nodeVar115 : f32;
var<private> nodeVar116 : f32;
var<private> nodeVar117 : f32;
var<private> nodeVar118 : f32;
var<private> nodeVar119 : f32;
var<private> nodeVar120 : f32;
var<private> nodeVar121 : vec2<f32>;
var<private> nodeVar122 : vec4<f32>;
var<private> nodeVar123 : vec3<f32>;
var<private> nodeVar124 : f32;
var<private> nodeVar125 : f32;
var<private> nodeVar126 : f32;
var<private> nodeVar127 : f32;
var<private> nodeVar128 : f32;
var<private> nodeVar129 : vec2<f32>;
var<private> nodeVar130 : vec4<f32>;
var<private> nodeVar131 : vec3<f32>;
var<private> nodeVar132 : vec3<f32>;
var<private> nodeVar133 : vec3<f32>;
var<private> nodeVar134 : vec3<f32>;
var<private> nodeVar135 : vec3<f32>;
var<private> indirectDiffuse : vec3<f32>;
var<private> nodeVar136 : vec3<f32>;
var<private> singleScatteringDielectric : vec3<f32>;
var<private> multiScatteringDielectric : vec3<f32>;
var<private> singleScatteringMetallic : vec3<f32>;
var<private> multiScatteringMetallic : vec3<f32>;
var<private> nodeVar137 : f32;
var<private> nodeVar138 : vec4<f32>;
var<private> nodeVar139 : vec3<f32>;
var<private> nodeVar140 : f32;
var<private> nodeVar141 : vec3<f32>;
var<private> nodeVar142 : vec3<f32>;
var<private> nodeVar143 : vec3<f32>;
var<private> nodeVar144 : vec3<f32>;
var<private> nodeVar145 : vec3<f32>;
var<private> nodeVar146 : vec3<f32>;
var<private> nodeVar147 : vec3<f32>;
var<private> nodeVar148 : f32;
var<private> nodeVar149 : f32;
var<private> nodeVar150 : f32;
var<private> nodeVar151 : vec3<f32>;
var<private> nodeVar152 : vec3<f32>;
var<private> nodeVar153 : vec3<f32>;
var<private> nodeVar154 : vec3<f32>;
var<private> nodeVar155 : vec3<f32>;
var<private> nodeVar156 : vec3<f32>;
var<private> nodeVar157 : f32;
var<private> nodeVar158 : vec4<f32>;
var<private> nodeVar159 : vec3<f32>;
var<private> nodeVar160 : f32;
var<private> nodeVar161 : vec3<f32>;
var<private> nodeVar162 : vec3<f32>;
var<private> nodeVar163 : vec3<f32>;
var<private> nodeVar164 : vec3<f32>;
var<private> nodeVar165 : vec3<f32>;
var<private> nodeVar166 : vec3<f32>;
var<private> nodeVar167 : vec3<f32>;
var<private> nodeVar168 : f32;
var<private> nodeVar169 : f32;
var<private> nodeVar170 : f32;
var<private> nodeVar171 : vec3<f32>;
var<private> nodeVar172 : vec3<f32>;
var<private> nodeVar173 : vec3<f32>;
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
var<private> indirectSpecular : vec3<f32>;
var<private> nodeVar190 : vec3<f32>;
var<private> nodeVar191 : vec3<f32>;
var<private> ambientOcclusion : f32;
var<private> nodeVar192 : vec3<f32>;
var<private> nodeVar193 : f32;
var<private> nodeVar194 : f32;
var<private> nodeVar195 : f32;
var<private> nodeVar196 : f32;
var<private> nodeVar197 : f32;
var<private> nodeVar198 : f32;
var<private> nodeVar199 : f32;
var<private> nodeVar200 : f32;
var<private> nodeVar201 : f32;
var<private> nodeVar202 : f32;
var<private> nodeVar203 : f32;
var<private> nodeVar204 : vec3<f32>;
var<private> totalDiffuse : vec3<f32>;
var<private> nodeVar205 : vec3<f32>;
var<private> totalSpecular : vec3<f32>;
var<private> nodeVar206 : vec3<f32>;
var<private> outgoingLight : vec3<f32>;
var<private> nodeVar207 : vec3<f32>;
var<private> nodeVar208 : f32;
var<private> nodeVar209 : vec4<f32>;

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
	@location( 2 ) v_positionWorld : vec3<f32>,
	@location( 3 ) v_positionViewDirection : vec3<f32>,
	@location( 4 ) nodeVarying7 : vec2<f32>,
	@location( 5 ) nodeVarying8 : vec4<f32>,
	@builtin( position ) fragCoord : vec4<f32> ) -> OutputStruct {

	// flow
	// code

	nodeVar0 = textureSample( nodeUniform0, nodeUniform0_sampler, nodeVarying7 );
	nodeVar1 = textureSample( nodeUniform1, nodeUniform1_sampler, nodeVarying7 );
	nodeVar2 = textureSample( nodeUniform2, nodeUniform2_sampler, nodeVarying7 );
	nodeVar3 = textureSample( nodeUniform3, nodeUniform3_sampler, nodeVarying7 );
	nodeVar4 = textureSample( nodeUniform4, nodeUniform4_sampler, nodeVarying7 );
	DiffuseColor = vec4<f32>( mix( mix( mix( mix( ( nodeVar0.xyz * vec3<f32>( 0.42, 1.0, 0.28 ) ), ( nodeVar1.xyz * vec3<f32>( 0.85, 1.0, 0.7 ) ), 0.7 ), nodeVar2.xyz, nodeVarying8.y ), nodeVar3.xyz, nodeVarying8.z ), nodeVar4.xyz, nodeVarying8.x ), 1.0 );
	DiffuseColor.w = ( DiffuseColor.w * object.nodeUniform5 );
	DiffuseColor.w = 1.0;
	Metalness = object.nodeUniform6;
	nodeVar5 = textureSample( nodeUniform7, nodeUniform7_sampler, nodeVarying7 );
	nodeVar6 = textureSample( nodeUniform8, nodeUniform8_sampler, nodeVarying7 );
	nodeVar7 = textureSample( nodeUniform9, nodeUniform9_sampler, nodeVarying7 );
	nodeVar8 = textureSample( nodeUniform10, nodeUniform10_sampler, nodeVarying7 );
	nodeVar9 = textureSample( nodeUniform11, nodeUniform11_sampler, nodeVarying7 );
	normalViewGeometry = normalize( v_normalViewGeometry );
	nodeVar10 = max( abs( dpdx( normalViewGeometry ) ), abs( - dpdy( normalViewGeometry ) ) );
	Roughness = min( ( max( mix( mix( mix( mix( vec4<f32>( nodeVar5.w ).x, vec4<f32>( nodeVar6.w ).x, 0.7 ), vec4<f32>( nodeVar7.w ).x, nodeVarying8.y ), vec4<f32>( nodeVar8.w ).x, nodeVarying8.z ), vec4<f32>( nodeVar9.w ).x, nodeVarying8.x ), 0.0525 ) + max( max( nodeVar10.x, nodeVar10.y ), nodeVar10.z ) ), 1.0 );
	SpecularColor = vec3<f32>( 0.04, 0.04, 0.04 );
	SpecularColorBlended = mix( vec3<f32>( 0.04, 0.04, 0.04 ), DiffuseColor.xyz, Metalness );
	SpecularF90 = 1.0;
	DiffuseContribution = ( DiffuseColor.xyz * vec3<f32>( ( 1.0 - object.nodeUniform6 ) ) );
	EmissiveColor = ( object.nodeUniform14 * vec3<f32>( object.nodeUniform15 ) );
	irradiance = vec3<f32>( 0.0, 0.0, 0.0 );
	NORMAL_normalView = normalViewGeometry;
	nodeVar11 = cross( - dpdy( v_positionView ), NORMAL_normalView );
	nodeVar12 = dpdx( nodeVarying7 );
	nodeVar13 = cross( NORMAL_normalView, dpdx( v_positionView ) );
	nodeVar14 = - dpdy( nodeVarying7 );
	nodeVar15 = ( ( nodeVar11 * vec3<f32>( nodeVar12.x ) ) + ( nodeVar13 * vec3<f32>( nodeVar14.x ) ) );
	nodeVar17 = ( ( nodeVar11 * vec3<f32>( nodeVar12.y ) ) + ( nodeVar13 * vec3<f32>( nodeVar14.y ) ) );
	nodeVar18 = max( dot( nodeVar15, nodeVar15 ), dot( nodeVar17, nodeVar17 ) );

	if ( ( nodeVar18 == 0.0 ) ) {

		nodeVar16 = 0.0;

	} else {

		nodeVar16 = inverseSqrt( nodeVar18 );

	}

	tangentViewFrame = ( nodeVar15 * vec3<f32>( nodeVar16 ) );
	NORMAL_tangentView = tangentViewFrame;
	bitangentViewFrame = ( nodeVar17 * nodeVar16 );
	NORMAL_bitangentView = bitangentViewFrame;
	NORMAL_TBNViewMatrix = mat3x3<f32>( NORMAL_tangentView, NORMAL_bitangentView, NORMAL_normalView );
	nodeVar19 = textureSample( nodeUniform7, nodeUniform7_sampler, nodeVarying7 );
	nodeVar20 = textureSample( nodeUniform8, nodeUniform8_sampler, nodeVarying7 );
	nodeVar21 = textureSample( nodeUniform9, nodeUniform9_sampler, nodeVarying7 );
	nodeVar22 = textureSample( nodeUniform10, nodeUniform10_sampler, nodeVarying7 );
	nodeVar23 = textureSample( nodeUniform11, nodeUniform11_sampler, nodeVarying7 );
	nodeVar24 = ( ( mix( mix( mix( mix( nodeVar19.xyz, nodeVar20.xyz, 0.7 ), nodeVar21.xyz, nodeVarying8.y ), nodeVar22.xyz, nodeVarying8.z ), nodeVar23.xyz, nodeVarying8.x ) * vec3<f32>( 2.0 ) ) - vec3<f32>( 1.0 ) );
	normalView = normalize( ( NORMAL_TBNViewMatrix * vec3<f32>( ( nodeVar24.xy * vec2<f32>( 0.65, 0.65 ) ), nodeVar24.z ) ) );
	nodeVar25 = vec4<f32>( normalView, 0.0 );
	nodeVar26 = ( nodeVar25 * render.cameraViewMatrix );
	nodeVar27 = normalize( nodeVar26.xyz );
	normalWorld = nodeVar27;
	nodeVar28 = dot( normalWorld, normalize( render.nodeUniform20 ) );
	nodeVar29 = ( nodeVar28 * 0.5 );
	nodeVar30 = ( nodeVar29 + 0.5 );
	nodeVar31 = mix( render.nodeUniform16, render.nodeUniform17, nodeVar30 );
	nodeVar32 = ( irradiance + nodeVar31 );
	irradiance = nodeVar32;
	nodeVar33 = ( render.nodeUniform21 - render.nodeUniform22 );
	nodeVar34 = vec4<f32>( nodeVar33, 0.0 );
	nodeVar35 = ( render.cameraViewMatrix * nodeVar34 );
	nodeVar36 = normalize( nodeVar35.xyz );
	nodeVar37 = nodeVar36;
	nodeVar38 = dot( normalView, nodeVar37 );
	shadowPositionWorld = v_positionWorld;
	nodeVar40 = ( render.nodeUniform24 * vec4<f32>( ( shadowPositionWorld + ( normalWorld * vec3<f32>( render.nodeUniform25 ) ) ), 1.0 ) );
	nodeVar41 = ( nodeVar40.xyz / vec3<f32>( nodeVar40.w ) );
	nodeVar42 = vec3<f32>( nodeVar41.x, ( 1.0 - nodeVar41.y ), ( nodeVar41.z + render.nodeUniform26 ) );

	if ( ( ( ( ( ( nodeVar42.x >= 0.0 ) && ( nodeVar42.x <= 1.0 ) ) && ( nodeVar42.y >= 0.0 ) ) && ( nodeVar42.y <= 1.0 ) ) && ( nodeVar42.z <= 1.0 ) ) ) {

		nodeVar43 = ( interleavedGradientNoise( fragCoord.xy ) * 6.28318530718 );
		nodeVar44 = ( render.nodeUniform28 * ( vec2<f32>( 1.0, 1.0 ) / render.nodeUniform29 ).x );
		nodeVar45 = ( nodeVar42.xy + ( vogelDiskSample( 0, 5, nodeVar43 ) * vec2<f32>( nodeVar44 ) ) );
		nodeVar46 = textureSampleCompare( nodeUniform27, nodeUniform27_sampler, nodeVar45, nodeVar42.z );
		nodeVar47 = ( nodeVar42.xy + ( vogelDiskSample( 1, 5, nodeVar43 ) * vec2<f32>( nodeVar44 ) ) );
		nodeVar48 = textureSampleCompare( nodeUniform27, nodeUniform27_sampler, nodeVar47, nodeVar42.z );
		nodeVar49 = ( nodeVar42.xy + ( vogelDiskSample( 2, 5, nodeVar43 ) * vec2<f32>( nodeVar44 ) ) );
		nodeVar50 = textureSampleCompare( nodeUniform27, nodeUniform27_sampler, nodeVar49, nodeVar42.z );
		nodeVar51 = ( nodeVar42.xy + ( vogelDiskSample( 3, 5, nodeVar43 ) * vec2<f32>( nodeVar44 ) ) );
		nodeVar52 = textureSampleCompare( nodeUniform27, nodeUniform27_sampler, nodeVar51, nodeVar42.z );
		nodeVar53 = ( nodeVar42.xy + ( vogelDiskSample( 4, 5, nodeVar43 ) * vec2<f32>( nodeVar44 ) ) );
		nodeVar54 = textureSampleCompare( nodeUniform27, nodeUniform27_sampler, nodeVar53, nodeVar42.z );
		nodeVar39 = ( ( ( ( ( nodeVar46 + nodeVar48 ) + nodeVar50 ) + nodeVar52 ) + nodeVar54 ) * 0.2 );

	} else {

		nodeVar39 = 1.0;

	}

	nodeVar55 = mix( 1.0, nodeVar39, render.nodeUniform30 );
	nodeVar56 = ( vec3<f32>( clamp( nodeVar38, 0.0, 1.0 ) ) * ( render.nodeUniform23 * vec3<f32>( nodeVar55 ) ) );
	nodeVar57 = nodeVar56;
	directDiffuse = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar58 = ( DiffuseContribution * vec3<f32>( 0.3183098861837907 ) );
	nodeVar59 = ( nodeVar57 * nodeVar58 );
	nodeVar60 = ( directDiffuse + nodeVar59 );
	directDiffuse = nodeVar60;
	directSpecular = vec3<f32>( 0.0, 0.0, 0.0 );
	positionViewDirection = normalize( v_positionViewDirection );
	nodeVar61 = normalize( ( nodeVar37 + positionViewDirection ) );
	nodeVar62 = clamp( dot( positionViewDirection, nodeVar61 ), 0.0, 1.0 );
	nodeVar63 = exp2( ( ( ( nodeVar62 * -5.55473 ) - 6.98316 ) * nodeVar62 ) );
	nodeVar64 = ( Roughness * Roughness );
	nodeVar65 = textureSample( nodeUniform31, nodeUniform31_sampler, vec2<f32>( Roughness, clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) );
	nodeVar66 = textureSample( nodeUniform31, nodeUniform31_sampler, vec2<f32>( Roughness, clamp( dot( normalView, nodeVar37 ), 0.0, 1.0 ) ) );
	nodeVar67 = ( SpecularColorBlended + ( ( vec3<f32>( 1.0 ) - SpecularColorBlended ) * vec3<f32>( 0.047619 ) ) );
	nodeVar68 = ( 1.0 - ( nodeVar65.xy.x + nodeVar65.xy.y ) );
	nodeVar69 = ( 1.0 - ( nodeVar66.xy.x + nodeVar66.xy.y ) );
	nodeVar70 = ( ( ( ( ( SpecularColorBlended * vec3<f32>( ( 1.0 - nodeVar63 ) ) ) + vec3<f32>( ( 1.0 * nodeVar63 ) ) ) * vec3<f32>( V_GGX_SmithCorrelated( nodeVar64, clamp( dot( normalView, nodeVar37 ), 0.0, 1.0 ), clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) ) ) * vec3<f32>( D_GGX( nodeVar64, clamp( dot( normalView, nodeVar61 ), 0.0, 1.0 ) ) ) ) + ( ( ( ( ( ( SpecularColorBlended * vec3<f32>( nodeVar65.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar65.xy.y ) ) ) * ( ( SpecularColorBlended * vec3<f32>( nodeVar66.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar66.xy.y ) ) ) ) * nodeVar67 ) / ( ( vec3<f32>( 1.0 ) - ( ( vec3<f32>( ( nodeVar68 * nodeVar69 ) ) * nodeVar67 ) * nodeVar67 ) ) + vec3<f32>( 0.000001 ) ) ) * vec3<f32>( ( nodeVar68 * nodeVar69 ) ) ) );
	nodeVar71 = ( nodeVar57 * nodeVar70 );
	nodeVar72 = ( directSpecular + nodeVar71 );
	directSpecular = nodeVar72;
	nodeVar73 = ( render.nodeUniform32 - render.nodeUniform33 );
	nodeVar74 = vec4<f32>( nodeVar73, 0.0 );
	nodeVar75 = ( render.cameraViewMatrix * nodeVar74 );
	nodeVar76 = normalize( nodeVar75.xyz );
	nodeVar77 = nodeVar76;
	nodeVar78 = dot( normalView, nodeVar77 );
	nodeVar79 = ( vec3<f32>( clamp( nodeVar78, 0.0, 1.0 ) ) * render.nodeUniform34 );
	nodeVar80 = nodeVar79;
	nodeVar81 = ( DiffuseContribution * vec3<f32>( 0.3183098861837907 ) );
	nodeVar82 = ( nodeVar80 * nodeVar81 );
	nodeVar83 = ( directDiffuse + nodeVar82 );
	directDiffuse = nodeVar83;
	nodeVar84 = normalize( ( nodeVar77 + positionViewDirection ) );
	nodeVar85 = clamp( dot( positionViewDirection, nodeVar84 ), 0.0, 1.0 );
	nodeVar86 = exp2( ( ( ( nodeVar85 * -5.55473 ) - 6.98316 ) * nodeVar85 ) );
	nodeVar87 = ( Roughness * Roughness );
	nodeVar88 = textureSample( nodeUniform31, nodeUniform31_sampler, vec2<f32>( Roughness, clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) );
	nodeVar89 = textureSample( nodeUniform31, nodeUniform31_sampler, vec2<f32>( Roughness, clamp( dot( normalView, nodeVar77 ), 0.0, 1.0 ) ) );
	nodeVar90 = ( SpecularColorBlended + ( ( vec3<f32>( 1.0 ) - SpecularColorBlended ) * vec3<f32>( 0.047619 ) ) );
	nodeVar91 = ( 1.0 - ( nodeVar88.xy.x + nodeVar88.xy.y ) );
	nodeVar92 = ( 1.0 - ( nodeVar89.xy.x + nodeVar89.xy.y ) );
	nodeVar93 = ( ( ( ( ( SpecularColorBlended * vec3<f32>( ( 1.0 - nodeVar86 ) ) ) + vec3<f32>( ( 1.0 * nodeVar86 ) ) ) * vec3<f32>( V_GGX_SmithCorrelated( nodeVar87, clamp( dot( normalView, nodeVar77 ), 0.0, 1.0 ), clamp( dot( normalView, positionViewDirection ), 0.0, 1.0 ) ) ) ) * vec3<f32>( D_GGX( nodeVar87, clamp( dot( normalView, nodeVar84 ), 0.0, 1.0 ) ) ) ) + ( ( ( ( ( ( SpecularColorBlended * vec3<f32>( nodeVar88.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar88.xy.y ) ) ) * ( ( SpecularColorBlended * vec3<f32>( nodeVar89.xy.x ) ) + vec3<f32>( ( 1.0 * nodeVar89.xy.y ) ) ) ) * nodeVar90 ) / ( ( vec3<f32>( 1.0 ) - ( ( vec3<f32>( ( nodeVar91 * nodeVar92 ) ) * nodeVar90 ) * nodeVar90 ) ) + vec3<f32>( 0.000001 ) ) ) * vec3<f32>( ( nodeVar91 * nodeVar92 ) ) ) );
	nodeVar94 = ( nodeVar80 * nodeVar93 );
	nodeVar95 = ( directSpecular + nodeVar94 );
	directSpecular = nodeVar95;
	radiance = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar96 = clamp( roughnessToMip( Roughness ), -2.0, object.nodeUniform35 );
	nodeVar97 = floor( nodeVar96 );
	nodeVar98 = nodeVar97;
	nodeVar99 = normalize( ( vec4<f32>( normalize( mix( reflect( ( - positionViewDirection ), normalView ), normalView, ( ( ( Roughness * Roughness ) * Roughness ) * Roughness ) ) ), 0.0 ) * render.cameraViewMatrix ).xyz );
	nodeVar100 = getFace( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( nodeVar99.x, ( - nodeVar99.y ), nodeVar99.z ), 1.0 ) ).xyz );
	nodeVar101 = max( ( 4.0 - nodeVar98 ), 0.0 );
	nodeVar98 = max( nodeVar98, 4.0 );
	nodeVar102 = exp2( nodeVar98 );
	nodeVar103 = ( ( getUV( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( nodeVar99.x, ( - nodeVar99.y ), nodeVar99.z ), 1.0 ) ).xyz, nodeVar100 ) * vec2<f32>( ( nodeVar102 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

	if ( ( nodeVar100 > 2.0 ) ) {

		nodeVar103.y = ( nodeVar103.y + nodeVar102 );
		nodeVar100 = ( nodeVar100 - 3.0 );
		

	}

	nodeVar103.x = ( nodeVar103.x + ( nodeVar100 * nodeVar102 ) );
	nodeVar103.x = ( nodeVar103.x + ( nodeVar101 * ( 3.0 * 16.0 ) ) );
	nodeVar103.y = ( nodeVar103.y + ( 4.0 * ( exp2( object.nodeUniform35 ) - nodeVar102 ) ) );
	nodeVar103.x = ( nodeVar103.x * object.nodeUniform37 );
	nodeVar103.y = ( nodeVar103.y * object.nodeUniform38 );
	nodeVar104 = textureSampleGrad( nodeUniform39, nodeUniform39_sampler, nodeVar103, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
	nodeVar105 = nodeVar104.xyz;
	nodeVar106 = fract( nodeVar96 );

	if ( ( nodeVar106 != 0.0 ) ) {

		nodeVar107 = ( nodeVar97 + 1.0 );
		nodeVar108 = getFace( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( nodeVar99.x, ( - nodeVar99.y ), nodeVar99.z ), 1.0 ) ).xyz );
		nodeVar109 = max( ( 4.0 - nodeVar107 ), 0.0 );
		nodeVar107 = max( nodeVar107, 4.0 );
		nodeVar110 = exp2( nodeVar107 );
		nodeVar111 = ( ( getUV( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( nodeVar99.x, ( - nodeVar99.y ), nodeVar99.z ), 1.0 ) ).xyz, nodeVar108 ) * vec2<f32>( ( nodeVar110 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

		if ( ( nodeVar108 > 2.0 ) ) {

			nodeVar111.y = ( nodeVar111.y + nodeVar110 );
			nodeVar108 = ( nodeVar108 - 3.0 );
			

		}

		nodeVar111.x = ( nodeVar111.x + ( nodeVar108 * nodeVar110 ) );
		nodeVar111.x = ( nodeVar111.x + ( nodeVar109 * ( 3.0 * 16.0 ) ) );
		nodeVar111.y = ( nodeVar111.y + ( 4.0 * ( exp2( object.nodeUniform35 ) - nodeVar110 ) ) );
		nodeVar111.x = ( nodeVar111.x * object.nodeUniform37 );
		nodeVar111.y = ( nodeVar111.y * object.nodeUniform38 );
		nodeVar112 = textureSampleGrad( nodeUniform39, nodeUniform39_sampler, nodeVar111, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
		nodeVar113 = nodeVar112.xyz;
		nodeVar105 = mix( nodeVar105, nodeVar113, nodeVar106 );
		

	}

	nodeVar114 = ( radiance + ( nodeVar105 * vec3<f32>( object.nodeUniform40 ) ) );
	radiance = nodeVar114;
	iblIrradiance = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar115 = clamp( roughnessToMip( 1.0 ), -2.0, object.nodeUniform35 );
	nodeVar116 = floor( nodeVar115 );
	nodeVar117 = nodeVar116;
	nodeVar118 = getFace( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz );
	nodeVar119 = max( ( 4.0 - nodeVar117 ), 0.0 );
	nodeVar117 = max( nodeVar117, 4.0 );
	nodeVar120 = exp2( nodeVar117 );
	nodeVar121 = ( ( getUV( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz, nodeVar118 ) * vec2<f32>( ( nodeVar120 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

	if ( ( nodeVar118 > 2.0 ) ) {

		nodeVar121.y = ( nodeVar121.y + nodeVar120 );
		nodeVar118 = ( nodeVar118 - 3.0 );
		

	}

	nodeVar121.x = ( nodeVar121.x + ( nodeVar118 * nodeVar120 ) );
	nodeVar121.x = ( nodeVar121.x + ( nodeVar119 * ( 3.0 * 16.0 ) ) );
	nodeVar121.y = ( nodeVar121.y + ( 4.0 * ( exp2( object.nodeUniform35 ) - nodeVar120 ) ) );
	nodeVar121.x = ( nodeVar121.x * object.nodeUniform37 );
	nodeVar121.y = ( nodeVar121.y * object.nodeUniform38 );
	nodeVar122 = textureSampleGrad( nodeUniform39, nodeUniform39_sampler, nodeVar121, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
	nodeVar123 = nodeVar122.xyz;
	nodeVar124 = fract( nodeVar115 );

	if ( ( nodeVar124 != 0.0 ) ) {

		nodeVar125 = ( nodeVar116 + 1.0 );
		nodeVar126 = getFace( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz );
		nodeVar127 = max( ( 4.0 - nodeVar125 ), 0.0 );
		nodeVar125 = max( nodeVar125, 4.0 );
		nodeVar128 = exp2( nodeVar125 );
		nodeVar129 = ( ( getUV( ( object.nodeUniform36 * vec4<f32>( vec3<f32>( normalWorld.x, ( - normalWorld.y ), normalWorld.z ), 1.0 ) ).xyz, nodeVar126 ) * vec2<f32>( ( nodeVar128 - 2.0 ) ) ) + vec2<f32>( 1.0 ) );

		if ( ( nodeVar126 > 2.0 ) ) {

			nodeVar129.y = ( nodeVar129.y + nodeVar128 );
			nodeVar126 = ( nodeVar126 - 3.0 );
			

		}

		nodeVar129.x = ( nodeVar129.x + ( nodeVar126 * nodeVar128 ) );
		nodeVar129.x = ( nodeVar129.x + ( nodeVar127 * ( 3.0 * 16.0 ) ) );
		nodeVar129.y = ( nodeVar129.y + ( 4.0 * ( exp2( object.nodeUniform35 ) - nodeVar128 ) ) );
		nodeVar129.x = ( nodeVar129.x * object.nodeUniform37 );
		nodeVar129.y = ( nodeVar129.y * object.nodeUniform38 );
		nodeVar130 = textureSampleGrad( nodeUniform39, nodeUniform39_sampler, nodeVar129, vec2<f32>( 0.0, 0.0 ), vec2<f32>( 0.0, 0.0 ) );
		nodeVar131 = nodeVar130.xyz;
		nodeVar123 = mix( nodeVar123, nodeVar131, nodeVar124 );
		

	}

	nodeVar132 = ( iblIrradiance + ( ( nodeVar123 * vec3<f32>( 3.141592653589793 ) ) * vec3<f32>( object.nodeUniform40 ) ) );
	iblIrradiance = nodeVar132;
	nodeVar133 = ( DiffuseContribution * vec3<f32>( 0.3183098861837907 ) );
	nodeVar134 = ( irradiance * nodeVar133 );
	nodeVar135 = nodeVar134;
	indirectDiffuse = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar136 = ( indirectDiffuse + nodeVar135 );
	indirectDiffuse = nodeVar136;
	singleScatteringDielectric = vec3<f32>( 0.0, 0.0, 0.0 );
	multiScatteringDielectric = vec3<f32>( 0.0, 0.0, 0.0 );
	singleScatteringMetallic = vec3<f32>( 0.0, 0.0, 0.0 );
	multiScatteringMetallic = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar137 = dot( normalView, positionViewDirection );
	nodeVar138 = textureSample( nodeUniform31, nodeUniform31_sampler, vec2<f32>( Roughness, clamp( nodeVar137, 0.0, 1.0 ) ) );
	nodeVar139 = ( SpecularColor * vec3<f32>( nodeVar138.xy.x ) );
	nodeVar140 = ( SpecularF90 * nodeVar138.xy.y );
	nodeVar141 = ( nodeVar139 + vec3<f32>( nodeVar140 ) );
	nodeVar142 = ( singleScatteringDielectric + nodeVar141 );
	singleScatteringDielectric = nodeVar142;
	nodeVar143 = ( vec3<f32>( 1.0 ) - SpecularColor );
	nodeVar144 = nodeVar143;
	nodeVar145 = ( nodeVar144 * vec3<f32>( 0.047619 ) );
	nodeVar146 = ( SpecularColor + nodeVar145 );
	nodeVar147 = ( nodeVar141 * nodeVar146 );
	nodeVar148 = ( nodeVar138.xy.x + nodeVar138.xy.y );
	nodeVar149 = ( 1.0 - nodeVar148 );
	nodeVar150 = nodeVar149;
	nodeVar151 = ( vec3<f32>( nodeVar150 ) * nodeVar146 );
	nodeVar152 = ( vec3<f32>( 1.0 ) - nodeVar151 );
	nodeVar153 = nodeVar152;
	nodeVar154 = ( nodeVar147 / nodeVar153 );
	nodeVar155 = ( nodeVar154 * vec3<f32>( nodeVar150 ) );
	nodeVar156 = ( multiScatteringDielectric + nodeVar155 );
	multiScatteringDielectric = nodeVar156;
	nodeVar157 = dot( normalView, positionViewDirection );
	nodeVar158 = textureSample( nodeUniform31, nodeUniform31_sampler, vec2<f32>( Roughness, clamp( nodeVar157, 0.0, 1.0 ) ) );
	nodeVar159 = ( DiffuseColor.xyz * vec3<f32>( nodeVar158.xy.x ) );
	nodeVar160 = ( SpecularF90 * nodeVar158.xy.y );
	nodeVar161 = ( nodeVar159 + vec3<f32>( nodeVar160 ) );
	nodeVar162 = ( singleScatteringMetallic + nodeVar161 );
	singleScatteringMetallic = nodeVar162;
	nodeVar163 = ( vec3<f32>( 1.0 ) - DiffuseColor.xyz );
	nodeVar164 = nodeVar163;
	nodeVar165 = ( nodeVar164 * vec3<f32>( 0.047619 ) );
	nodeVar166 = ( DiffuseColor.xyz + nodeVar165 );
	nodeVar167 = ( nodeVar161 * nodeVar166 );
	nodeVar168 = ( nodeVar158.xy.x + nodeVar158.xy.y );
	nodeVar169 = ( 1.0 - nodeVar168 );
	nodeVar170 = nodeVar169;
	nodeVar171 = ( vec3<f32>( nodeVar170 ) * nodeVar166 );
	nodeVar172 = ( vec3<f32>( 1.0 ) - nodeVar171 );
	nodeVar173 = nodeVar172;
	nodeVar174 = ( nodeVar167 / nodeVar173 );
	nodeVar175 = ( nodeVar174 * vec3<f32>( nodeVar170 ) );
	nodeVar176 = ( multiScatteringMetallic + nodeVar175 );
	multiScatteringMetallic = nodeVar176;
	nodeVar177 = mix( singleScatteringDielectric, singleScatteringMetallic, Metalness );
	nodeVar178 = ( radiance * nodeVar177 );
	nodeVar179 = mix( multiScatteringDielectric, multiScatteringMetallic, Metalness );
	nodeVar180 = ( iblIrradiance * vec3<f32>( 0.3183098861837907 ) );
	nodeVar181 = ( nodeVar179 * nodeVar180 );
	nodeVar182 = ( nodeVar178 + nodeVar181 );
	nodeVar183 = nodeVar182;
	nodeVar184 = ( singleScatteringDielectric + multiScatteringDielectric );
	nodeVar185 = ( vec3<f32>( 1.0 ) - nodeVar184 );
	nodeVar186 = nodeVar185;
	nodeVar187 = ( DiffuseContribution * nodeVar186 );
	nodeVar188 = ( nodeVar187 * nodeVar180 );
	nodeVar189 = nodeVar188;
	indirectSpecular = vec3<f32>( 0.0, 0.0, 0.0 );
	nodeVar190 = ( indirectSpecular + nodeVar183 );
	indirectSpecular = nodeVar190;
	nodeVar191 = ( indirectDiffuse + nodeVar189 );
	indirectDiffuse = nodeVar191;
	ambientOcclusion = 1.0;
	nodeVar192 = ( indirectDiffuse * vec3<f32>( ambientOcclusion ) );
	indirectDiffuse = nodeVar192;
	nodeVar193 = dot( normalView, positionViewDirection );
	nodeVar194 = ( clamp( nodeVar193, 0.0, 1.0 ) + ambientOcclusion );
	nodeVar195 = ( Roughness * -16.0 );
	nodeVar196 = ( 1.0 - nodeVar195 );
	nodeVar197 = nodeVar196;
	nodeVar198 = ( - nodeVar197 );
	nodeVar199 = exp2( nodeVar198 );
	nodeVar200 = pow( nodeVar194, nodeVar199 );
	nodeVar201 = ( 1.0 - nodeVar200 );
	nodeVar202 = nodeVar201;
	nodeVar203 = ( ambientOcclusion - nodeVar202 );
	nodeVar204 = ( indirectSpecular * vec3<f32>( clamp( nodeVar203, 0.0, 1.0 ) ) );
	indirectSpecular = nodeVar204;
	nodeVar205 = ( directDiffuse + indirectDiffuse );
	totalDiffuse = nodeVar205;
	nodeVar206 = ( directSpecular + indirectSpecular );
	totalSpecular = nodeVar206;
	nodeVar207 = ( totalDiffuse + totalSpecular );
	outgoingLight = nodeVar207;
	Output = max( vec4<f32>( ( outgoingLight + EmissiveColor ), DiffuseColor.w ), vec4<f32>( 0.0 ) );
	nodeVar208 = ( - v_positionView.z );
	nodeVar209 = vec4<f32>( mix( Output.xyz, render.nodeUniform41, ( 1.0 - exp( ( - ( ( ( render.nodeUniform42 * render.nodeUniform42 ) * nodeVar208 ) * nodeVar208 ) ) ) ) ), Output.w );
	Output = nodeVar209;

	// result

	output.color = nodeVar209;

	return output;

}
