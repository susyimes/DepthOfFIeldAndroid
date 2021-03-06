#extension GL_OES_EGL_image_external : require
precision highp float;

uniform samplerExternalOES surface_texture;
uniform samplerExternalOES depth_texture;
uniform float cutoff;
varying vec2 v_TextureCoordinates;

float remap(float value, float inputMin, float inputMax, float outputMin, float outputMax)
{
    return (value - inputMin) * ((outputMax - outputMin) / (inputMax - inputMin)) + outputMin;
}



//uniform sampler2D uTexture; //Image to be processed
//uniform sampler2D uDepth; //Linear depth, where 1.0 == far plane
uniform vec2 uPixelSize; //The size of a pixel: vec2(1.0/width, 1.0/height)
//uniform float uFar; // Far plane
const float uFar = 1.0;
const float GOLDEN_ANGLE = 2.39996323;
const float MAX_BLUR_SIZE = 20.0;
const float RAD_SCALE = 4.5; // Smaller = nicer blur, larger = faster

float getBlurSize(float depth, float focusPoint, float focusScale)
{
	float coc = clamp((1.0 / focusPoint - 1.0 / depth)*focusScale, -1.0, 1.0);
	return abs(coc) * MAX_BLUR_SIZE;
}

vec3 depthOfField(vec2 texCoord, float focusPoint, float focusScale)
{
	float centerDepth = texture2D(depth_texture, texCoord).r * uFar;
	float centerSize = getBlurSize(centerDepth, focusPoint, focusScale);
	vec3 color = texture2D(surface_texture, texCoord).rgb;
	float tot = 1.0;
	float radius = RAD_SCALE;
	for (float ang = 0.0; radius<MAX_BLUR_SIZE; ang += GOLDEN_ANGLE)
	{
		vec2 tc = texCoord + vec2(cos(ang), sin(ang)) * uPixelSize * radius;
		vec3 sampleColor = texture2D(surface_texture, tc).rgb;
		float sampleDepth = texture2D(depth_texture, tc).r * uFar;
		float sampleSize = getBlurSize(sampleDepth, focusPoint, focusScale);
		if (sampleDepth > centerDepth){
			sampleSize = clamp(sampleSize, 0.0, centerSize*2.0);
			}
		float m = smoothstep(radius-0.5, radius+0.5, sampleSize);
		color += mix(color/tot, sampleColor, m);
		tot += 1.0;
		radius += RAD_SCALE/radius;
	}
	return color /= tot;
}


void main()                    		
{
    vec2 textureCoordinates = v_TextureCoordinates;
    textureCoordinates.y = 1.0 - textureCoordinates.y;

 	vec4 surfaceTextureColor = texture2D(surface_texture, textureCoordinates);
 	vec4 surfaceDepthTextureColor = texture2D(depth_texture, textureCoordinates);
    vec3 blur = depthOfField(textureCoordinates,0.5, 1.0);
    gl_FragColor = vec4(blur.rgb,1.0);
}