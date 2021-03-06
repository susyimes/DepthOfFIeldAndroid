package no.danielzeller.depthoffield.opengl


import android.content.Context
import android.opengl.GLES11Ext
import android.opengl.GLES20.*
import android.opengl.GLES30

class TextureShaderProgram(vertexShaderResourceId: Int, fragmentShaderResourceId: Int) :
    ShaderProgram(vertexShaderResourceId, fragmentShaderResourceId) {

    private var uMatrixLocation: Int = 0
    private var uTextureUnitLocation: Int = 0
    private var uTextureDepthUnitLocation: Int = 0
    private var uCutoffUnitLocation: Int = 0
    private var uSizeLocation: Int = 0
    override fun load(context: Context) {
        super.load(context)

        uMatrixLocation = glGetUniformLocation(program, U_MATRIX)
        uTextureUnitLocation = glGetUniformLocation(program, U_TEXTURE_UNIT)
        uTextureDepthUnitLocation = glGetUniformLocation(program, U_DEPTH_TEXTURE_UNIT)
        positionAttributeLocation = glGetAttribLocation(program, A_POSITION)
        textureCoordinatesAttributeLocation = glGetAttribLocation(program, A_TEXTURE_COORDINATES)
        uCutoffUnitLocation = glGetUniformLocation(program, A_CUTOFF_LOCATION)
        uSizeLocation = glGetUniformLocation(program, "uPixelSize")

    }

    fun setUniforms(matrix: FloatArray, textureId: Int, depthTextureId: Int, cutoffFactor: Float, w: Float, h: Float) {

        glUniformMatrix4fv(uMatrixLocation, 1, false, matrix, 0)

        glActiveTexture(GLES30.GL_TEXTURE0)
        glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        glActiveTexture(GLES30.GL_TEXTURE0 + 1)
        glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, depthTextureId)
        glUniform1i(uTextureUnitLocation, 0)
        glUniform1i(uTextureDepthUnitLocation, 1)
        glUniform2f(uSizeLocation, w, h)
        glUniform1f(uCutoffUnitLocation, cutoffFactor)
    }
}
