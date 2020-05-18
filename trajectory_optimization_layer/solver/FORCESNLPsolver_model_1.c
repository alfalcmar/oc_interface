/* This function was automatically generated by CasADi */
#ifdef __cplusplus
extern "C" {
#endif

#ifdef CODEGEN_PREFIX
#define NAMESPACE_CONCAT(NS, ID) _NAMESPACE_CONCAT(NS, ID)
#define _NAMESPACE_CONCAT(NS, ID) NS ## ID
#define CASADI_PREFIX(ID) NAMESPACE_CONCAT(CODEGEN_PREFIX, ID)
#else /* CODEGEN_PREFIX */
#define CASADI_PREFIX(ID) FORCESNLPsolver_model_1_ ## ID
#endif /* CODEGEN_PREFIX */

#include <math.h>

#include "FORCESNLPsolver/include/FORCESNLPsolver.h"

#define PRINTF printf
FORCESNLPsolver_float CASADI_PREFIX(sq)(FORCESNLPsolver_float x) { return x*x;}
#define sq(x) CASADI_PREFIX(sq)(x)

FORCESNLPsolver_float CASADI_PREFIX(sign)(FORCESNLPsolver_float x) { return x<0 ? -1 : x>0 ? 1 : x;}
#define sign(x) CASADI_PREFIX(sign)(x)

static const solver_int32_default CASADI_PREFIX(s0)[] = {9, 1, 0, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8};
#define s0 CASADI_PREFIX(s0)
static const solver_int32_default CASADI_PREFIX(s1)[] = {10, 1, 0, 10, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
#define s1 CASADI_PREFIX(s1)
static const solver_int32_default CASADI_PREFIX(s2)[] = {1, 1, 0, 1, 0};
#define s2 CASADI_PREFIX(s2)
static const solver_int32_default CASADI_PREFIX(s3)[] = {1, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0};
#define s3 CASADI_PREFIX(s3)
static const solver_int32_default CASADI_PREFIX(s4)[] = {1, 9, 0, 0, 0, 0, 1, 2, 3, 3, 3, 3, 0, 0, 0};
#define s4 CASADI_PREFIX(s4)
static const solver_int32_default CASADI_PREFIX(s5)[] = {6, 1, 0, 6, 0, 1, 2, 3, 4, 5};
#define s5 CASADI_PREFIX(s5)
static const solver_int32_default CASADI_PREFIX(s6)[] = {6, 9, 0, 2, 4, 6, 7, 8, 9, 11, 13, 15, 0, 3, 1, 4, 2, 5, 0, 1, 2, 0, 3, 1, 4, 2, 5};
#define s6 CASADI_PREFIX(s6)
/* evaluate_stages */
solver_int32_default FORCESNLPsolver_model_1(const FORCESNLPsolver_float **arg, FORCESNLPsolver_float **res) 
{
    FORCESNLPsolver_float a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,a31,a32,a33,a34,a35;
    a0=arg[0] ? arg[0][0] : 0;
    a1=sq(a0);
    a2=arg[0] ? arg[0][1] : 0;
    a3=sq(a2);
    a1=(a1+a3);
    a3=arg[0] ? arg[0][2] : 0;
    a4=sq(a3);
    a1=(a1+a4);
    a4=arg[0] ? arg[0][5] : 0;
    a5=arg[1] ? arg[1][2] : 0;
    a5=(a4-a5);
    a6=sq(a5);
    a7=100.;
    a6=(a7*a6);
    a1=(a1+a6);
    a6=arg[0] ? arg[0][3] : 0;
    a8=arg[1] ? arg[1][8] : 0;
    a9=(a6-a8);
    a10=sq(a9);
    a11=1.0000000000000000e-03;
    a10=(a11+a10);
    a12=arg[0] ? arg[0][4] : 0;
    a13=arg[1] ? arg[1][9] : 0;
    a14=(a12-a13);
    a15=sq(a14);
    a10=(a10+a15);
    a15=(a6-a8);
    a16=sq(a15);
    a17=(a12-a13);
    a18=sq(a17);
    a16=(a16+a18);
    a18=sq(a4);
    a16=(a16+a18);
    a18=sq(a16);
    a19=(a18*a10);
    a19=(a11+a19);
    a20=(a6-a8);
    a21=(a20*a4);
    a22=arg[0] ? arg[0][6] : 0;
    a23=arg[1] ? arg[1][6] : 0;
    a23=(a22-a23);
    a24=(a21*a23);
    a25=(a12-a13);
    a26=(a25*a4);
    a27=arg[0] ? arg[0][7] : 0;
    a28=arg[1] ? arg[1][7] : 0;
    a28=(a27-a28);
    a29=(a26*a28);
    a24=(a24+a29);
    a29=(a6-a8);
    a30=sq(a29);
    a31=(a12-a13);
    a32=sq(a31);
    a30=(a30+a32);
    a32=arg[0] ? arg[0][8] : 0;
    a33=(a32*a30);
    a24=(a24-a33);
    a33=sq(a24);
    a33=(a33/a19);
    a34=100000.;
    a35=(a34*a33);
    a1=(a1+a35);
    if (res[0]!=0) res[0][0]=a1;
    a1=(a0+a0);
    if (res[1]!=0) res[1][0]=a1;
    a1=(a2+a2);
    if (res[1]!=0) res[1][1]=a1;
    a1=(a3+a3);
    if (res[1]!=0) res[1][2]=a1;
    a24=(a24+a24);
    a1=(a34/a19);
    a24=(a24*a1);
    a23=(a23*a24);
    a1=(a4*a23);
    a29=(a29+a29);
    a35=(a32*a24);
    a29=(a29*a35);
    a1=(a1-a29);
    a15=(a15+a15);
    a16=(a16+a16);
    a33=(a33/a19);
    a34=(a34*a33);
    a10=(a10*a34);
    a16=(a16*a10);
    a15=(a15*a16);
    a1=(a1-a15);
    a9=(a9+a9);
    a18=(a18*a34);
    a9=(a9*a18);
    a1=(a1-a9);
    if (res[1]!=0) res[1][3]=a1;
    a28=(a28*a24);
    a1=(a4*a28);
    a31=(a31+a31);
    a31=(a31*a35);
    a1=(a1-a31);
    a17=(a17+a17);
    a17=(a17*a16);
    a1=(a1-a17);
    a14=(a14+a14);
    a14=(a14*a18);
    a1=(a1-a14);
    if (res[1]!=0) res[1][4]=a1;
    a25=(a25*a28);
    a20=(a20*a23);
    a25=(a25+a20);
    a20=(a4+a4);
    a20=(a20*a16);
    a25=(a25-a20);
    a5=(a5+a5);
    a7=(a7*a5);
    a25=(a25+a7);
    if (res[1]!=0) res[1][5]=a25;
    a21=(a21*a24);
    if (res[1]!=0) res[1][6]=a21;
    a26=(a26*a24);
    if (res[1]!=0) res[1][7]=a26;
    a30=(a30*a24);
    a30=(-a30);
    if (res[1]!=0) res[1][8]=a30;
    a8=(a6-a8);
    a30=sq(a8);
    a13=(a12-a13);
    a24=sq(a13);
    a30=(a30+a24);
    a30=(a30+a11);
    a11=sqrt(a30);
    a24=atan2(a11,a4);
    if (res[2]!=0) res[2][0]=a24;
    a8=(a8+a8);
    a24=sq(a4);
    a30=(a30+a24);
    a24=(a4/a30);
    a26=(a11+a11);
    a24=(a24/a26);
    a8=(a8*a24);
    if (res[3]!=0) res[3][0]=a8;
    a13=(a13+a13);
    a13=(a13*a24);
    if (res[3]!=0) res[3][1]=a13;
    a11=(a11/a30);
    a11=(-a11);
    if (res[3]!=0) res[3][2]=a11;
    a11=1.0000000000000001e-01;
    a30=(a11*a0);
    a30=(a22+a30);
    a13=2.;
    a30=(a13*a30);
    a30=(a22+a30);
    a24=(a11*a0);
    a24=(a22+a24);
    a24=(a13*a24);
    a30=(a30+a24);
    a24=2.0000000000000001e-01;
    a8=(a24*a0);
    a8=(a22+a8);
    a30=(a30+a8);
    a8=3.3333333333333333e-02;
    a30=(a8*a30);
    a6=(a6+a30);
    if (res[4]!=0) res[4][0]=a6;
    a6=(a11*a2);
    a6=(a27+a6);
    a6=(a13*a6);
    a6=(a27+a6);
    a30=(a11*a2);
    a30=(a27+a30);
    a30=(a13*a30);
    a6=(a6+a30);
    a30=(a24*a2);
    a30=(a27+a30);
    a6=(a6+a30);
    a6=(a8*a6);
    a12=(a12+a6);
    if (res[4]!=0) res[4][1]=a12;
    a12=(a11*a3);
    a12=(a32+a12);
    a12=(a13*a12);
    a12=(a32+a12);
    a11=(a11*a3);
    a11=(a32+a11);
    a11=(a13*a11);
    a12=(a12+a11);
    a11=(a24*a3);
    a11=(a32+a11);
    a12=(a12+a11);
    a12=(a8*a12);
    a4=(a4+a12);
    if (res[4]!=0) res[4][2]=a4;
    a4=(a13*a0);
    a4=(a0+a4);
    a12=(a13*a0);
    a4=(a4+a12);
    a4=(a4+a0);
    a4=(a8*a4);
    a22=(a22+a4);
    if (res[4]!=0) res[4][3]=a22;
    a22=(a13*a2);
    a22=(a2+a22);
    a4=(a13*a2);
    a22=(a22+a4);
    a22=(a22+a2);
    a22=(a8*a22);
    a27=(a27+a22);
    if (res[4]!=0) res[4][4]=a27;
    a27=(a13*a3);
    a27=(a3+a27);
    a13=(a13*a3);
    a27=(a27+a13);
    a27=(a27+a3);
    a8=(a8*a27);
    a32=(a32+a8);
    if (res[4]!=0) res[4][5]=a32;
    a32=2.0000000000000004e-02;
    if (res[5]!=0) res[5][0]=a32;
    if (res[5]!=0) res[5][1]=a24;
    if (res[5]!=0) res[5][2]=a32;
    if (res[5]!=0) res[5][3]=a24;
    if (res[5]!=0) res[5][4]=a32;
    if (res[5]!=0) res[5][5]=a24;
    a32=1.;
    if (res[5]!=0) res[5][6]=a32;
    if (res[5]!=0) res[5][7]=a32;
    if (res[5]!=0) res[5][8]=a32;
    if (res[5]!=0) res[5][9]=a24;
    if (res[5]!=0) res[5][10]=a32;
    if (res[5]!=0) res[5][11]=a24;
    if (res[5]!=0) res[5][12]=a32;
    if (res[5]!=0) res[5][13]=a24;
    if (res[5]!=0) res[5][14]=a32;
    return 0;
}

solver_int32_default FORCESNLPsolver_model_1_init(solver_int32_default *f_type, solver_int32_default *n_in, solver_int32_default *n_out, solver_int32_default *sz_arg, solver_int32_default *sz_res) 
{
    *f_type = 1;
    *n_in = 2;
    *n_out = 6;
    *sz_arg = 2;
    *sz_res = 6;
    return 0;
}

solver_int32_default FORCESNLPsolver_model_1_sparsity(solver_int32_default i, solver_int32_default *nrow, solver_int32_default *ncol, const solver_int32_default **colind, const solver_int32_default **row) 
{
    const solver_int32_default *s;
    switch (i) 
    {
      case 0:
        s = s0;
        break;
      case 1:
        s = s1;
        break;
      case 2:
      case 4:
        s = s2;
        break;
      case 3:
        s = s3;
        break;
      case 5:
        s = s4;
        break;
      case 6:
        s = s5;
        break;
      case 7:
        s = s6;
        break;
      default:
        return 1;
    }
    
    *nrow = s[0];
    *ncol = s[1];
    *colind = s + 2;
    *row = s + 2 + (*ncol + 1);
    return 0;
}

solver_int32_default FORCESNLPsolver_model_1_work(solver_int32_default *sz_iw, solver_int32_default *sz_w) 
{
    if (sz_iw) *sz_iw = 0;
    if (sz_w) *sz_w = 36;
    return 0;
}


#ifdef __cplusplus
} /* extern "C" */
#endif