export inline void dotProduct(uniform const float v1[], uniform const float v2[],
                       uniform int count, uniform float vout[]) {   
    foreach(i = 0 ... count) {
        vout[i] += v1[i] * v2[i];
    }
}