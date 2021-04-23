cap mata mata drop GetCritVal()
mata:
  function GetCritVal(real scalar eps1, real scalar signif, real scalar l, real scalar q, string scalar type)
  {
    /// critical values need to be divided by number of regressors with breaks for hypothesis 1 and 2. Not for hypothesis 3!
    if (strlower(type) == "fll1") {
      res = critval_fll1(eps1,signif,l,q) 
    }
    else if (strlower(type) == "supf") {
      res = critval_supF( eps1 ,  signif, l, q) / q
    }
    else  {
      res = critval_udwdmax(eps1,signif,q,type) / q
    }

    return(res)
  }

end


cap mata mata drop critval_fll1()

mata:
function critval_fll1(real scalar eps1 , real scalar signif, real scalar l, real scalar q)
{
  cv = J(10,10,0)
  if (eps1 == .05) {
  
    if (signif == 0.9) {
    cv=( ///
     8.02, 9.56,10.45,11.07,11.65,12.07,12.47,12.70,13.07,13.34\ ///
    11.02,12.79,13.72,14.45,14.90,15.35,15.81,16.12,16.44,16.58\ ///
    13.43,15.26,16.38,17.07,17.52,17.91,18.35,18.61,18.92,19.19\ ///
    15.53,17.54,18.55,19.30,19.80,20.15,20.48,20.73,20.94,21.10\ ///
    17.42,19.38,20.46,21.37,21.96,22.47,22.77,23.23,23.56,23.81\ ///
    19.38,21.51,22.81,23.64,24.19,24.59,24.86,25.27,25.53,25.87\ ///
    21.23,23.41,24.51,25.07,25.75,26.30,26.74,27.06,27.46,27.70\ ///
    22.92,25.15,26.38,27.09,27.77,28.15,28.61,28.90,29.19,29.49\ ///
    24.75,26.99,28.11,29.03,29.69,30.18,30.61,30.93,31.14,31.46\ ///
    26.13,28.40,29.68,30.62,31.25,31.81,32.37,32.78,33.09,33.53 ///
    )
    }
    if (signif == 0.95) {
    cv=( ///
     9.63,11.14,12.16,12.83,13.45,14.05,14.29,14.50,14.69,14.88\ ///
    12.89,14.50,15.42,16.16,16.61,17.02,17.27,17.55,17.76,17.97\ ///
    15.37,17.15,17.97,18.72,19.23,19.59,19.94,20.31,21.05,21.20\ ///
    17.60,19.33,20.22,20.75,21.15,21.55,21.90,22.27,22.63,22.83\ ///
    19.50,21.43,22.57,23.33,23.90,24.34,24.62,25.14,25.34,25.51\ ///
    21.59,23.72,24.66,25.29,25.89,26.36,26.84,27.10,27.26,27.40\ ///
    23.50,25.17,26.34,27.19,27.96,28.25,28.64,28.84,28.97,29.14\ ///
    25.22,27.18,28.21,28.99,29.54,30.05,30.45,30.79,31.29,31.75\ ///
    27.08,29.10,30.24,30.99,31.48,32.46,32.71,32.89,33.15,33.43\ ///
    28.49,30.65,31.90,32.83,33.57,34.27,34.53,35.01,35.33,35.65 ///
    )
    }
    if (signif == 0.975) {
    cv=( ///
    11.17,12.88,14.05,14.50,15.03,15.37,15.56,15.73,16.02,16.39\ ///
    14.53,16.19,17.02,17.55,17.98,18.15,18.46,18.74,18.98,19.22\ ///
    17.17,18.75,19.61,20.31,21.33,21.59,21.78,22.07,22.41,22.73\ ///
    19.35,20.76,21.60,22.27,22.84,23.44,23.74,24.14,24.36,24.54\ ///
    21.47,23.34,24.37,25.14,25.58,25.79,25.96,26.39,26.60,26.84\ ///
    23.73,25.41,26.37,27.10,27.42,28.02,28.39,28.75,29.13,29.44\ ///
    25.23,27.24,28.25,28.84,29.14,29.72,30.41,30.76,31.09,31.43\ ///
    27.21,29.01,30.09,30.79,31.80,32.50,32.81,32.86,33.20,33.60\ ///
    29.13,31.04,32.48,32.89,33.47,33.98,34.25,34.74,34.88,35.07\ ///
    30.67,32.87,34.27,35.01,35.86,36.32,36.65,36.90,37.15,37.41 ///
    )
    }
    if (signif == 0.99) {
    cv=( ///
    13.58,15.03,15.62,16.39,16.60,16.90,17.04,17.27,17.32,17.61\ ///
    16.64,17.98,18.66,19.22,20.03,20.87,20.97,21.19,21.43,21.74\ ///
    19.25,21.33,22.01,22.73,23.13,23.48,23.70,23.79,23.84,24.59\ ///
    21.20,22.84,24.04,24.54,24.96,25.36,25.51,25.58,25.63,25.88\ ///
    23.99,25.58,26.32,26.84,27.39,27.86,27.90,28.32,28.38,28.39\ ///
    25.95,27.42,28.60,29.44,30.18,30.52,30.64,30.99,31.25,31.33\ ///
    28.01,29.14,30.61,31.43,32.56,32.75,32.90,33.25,33.25,33.85\ ///
    29.60,31.80,32.84,33.60,34.23,34.57,34.75,35.01,35.50,35.65\ ///
    31.66,33.47,34.60,35.07,35.49,37.08,37.12,37.23,37.47,37.68\ ///
    33.62,35.86,36.68,37.41,38.20,38.70,38.91,39.09,39.11,39.12 ///
    )
    }
  }


  if (eps1 == .10) {
  
    if (signif == 0.9) {
    cv=( ///
    7.42, 9.05, 9.97, 10.49, 10.91, 11.29, 11.86, 12.26, 12.57, 12.84\ /// 
    10.37, 12.19, 13.20, 13.79, 14.37, 14.68, 15.07, 15.42, 15.81, 16.09\ ///
    12.77, 14.54, 15.64, 16.46, 16.94, 17.35, 17.68, 17.93, 18.35, 18.55\ /// 
    14.81, 16.70, 17.84, 18.51, 19.13, 19.50, 19.93, 20.15, 20.46, 20.67\ ///
    16.65, 18.61, 19.74, 20.46, 21.04, 21.56, 21.96, 22.46, 22.72, 22.96\ ///
    18.65, 20.63, 22.03, 22.90, 23.57, 24.08, 24.38, 24.73, 25.10, 25.29\ ///
    20.34, 22.55, 23.84, 24.59, 24.97, 25.48, 26.18, 26.48, 26.86, 26.97\ ///
    22.01, 24.24, 25.49, 26.31, 26.98, 27.55, 27.92, 28.16, 28.64, 28.89\ ///
    23.79, 26.14, 27.34, 28.16, 28.83, 29.33, 29.86, 30.23, 30.46, 30.74\ ///
    25.29, 27.59, 28.75, 29.71, 30.35, 30.99, 31.41, 31.82, 32.25, 32.61 ///
    )
    }

    if (signif == 0.95) {
    cv=( ///
    9.10, 10.55, 11.36, 12.35, 12.97, 13.45, 13.88, 14.12, 14.45, 14.51\ ///
    12.25, 13.83, 14.73, 15.46, 16.13, 16.55, 16.82, 17.07, 17.34, 17.58\ ///
    14.60, 16.53, 17.43, 17.98, 18.61, 19.02, 19.25, 19.61, 19.94, 20.35\ ///
    16.76, 18.56, 19.53, 20.24, 20.72, 21.13, 21.55, 21.83, 22.08, 22.40\ ///
    18.68, 20.57, 21.60, 22.55, 23.00, 23.63, 24.13, 24.48, 24.82, 25.14\ ///
    20.76, 23.01, 24.14, 24.77, 25.48, 25.89, 26.25, 26.77, 26.96, 27.14\ ///
    22.62, 24.64, 25.57, 26.54, 27.04, 27.51, 28.14, 28.44, 28.74, 28.87\ ///
    24.34, 26.42, 27.66, 28.25, 28.99, 29.34, 29.86, 30.29, 30.50, 30.68\ ///
    26.20, 28.23, 29.44, 30.31, 30.77, 31.35, 31.91, 32.60, 32.71, 32.86\ ///
    27.64, 29.78, 31.02, 31.90, 32.71, 33.32, 33.95, 34.29, 34.52, 34.81 ///
    )
    }

    if (signif == 0.975) {
    cv=( ///
    10.56, 12.37, 13.46, 14.13, 14.51, 14.88, 15.37, 15.47, 15.62, 15.79\ ///
    13.86, 15.51, 16.55, 17.07, 17.58, 17.98, 18.19, 18.55, 18.92, 19.02\ ///
    16.55, 17.99, 19.06, 19.65, 20.35, 21.40, 21.57, 21.76, 22.07, 22.53\ ///
    18.62, 20.30, 21.18, 21.86, 22.40, 22.83, 23.42, 23.63, 23.77, 24.14\ ///
    20.59, 22.57, 23.66, 24.50, 25.14, 25.46, 25.77, 25.87, 26.02, 26.34\ ///
    23.05, 24.79, 25.91, 26.80, 27.14, 27.42, 27.85, 28.10, 28.55, 28.89\ ///
    24.65, 26.56, 27.53, 28.51, 28.87, 29.08, 29.43, 29.85, 30.35, 30.68\ ///
    26.50, 28.29, 29.36, 30.34, 30.68, 31.82, 32.42, 32.64, 32.82, 33.08\ ///
    28.25, 30.31, 31.41, 32.60, 32.86, 33.39, 33.79, 34.00, 34.35, 34.75\ ///
    29.80, 31.90, 33.34, 34.31, 34.81, 35.65, 36.23, 36.36, 36.65, 36.72 ///
    )
    }

    if (signif == 0.99) {
    cv=( ///
    13.00, 14.51, 15.44, 15.73, 16.39, 16.60, 16.78, 16.90, 16.99, 17.04\ ///
    16.19, 17.58, 18.31, 18.98, 19.63, 20.09, 20.30, 20.87, 20.97, 21.13\ ///
    18.72, 20.35, 21.60, 22.35, 22.96, 23.37, 23.53, 23.71, 23.79, 23.84\ ///
    20.75, 22.40, 23.55, 24.13, 24.54, 24.96, 25.11, 25.50, 25.56, 25.58\ ///
    23.12, 25.14, 25.79, 26.32, 26.60, 26.96, 27.39, 27.51, 27.75, 27.75\ ///
    25.50, 27.14, 27.92, 28.75, 29.44, 30.12, 30.18, 30.29, 30.52, 30.64\ ///
    27.19, 28.87, 29.51, 30.43, 31.38, 32.56, 32.62, 32.87, 32.90, 33.25\ ///
    29.01, 30.68, 32.52, 32.86, 33.27, 34.10, 34.26, 34.38, 34.57, 34.72\ ///
    30.81, 32.86, 33.92, 34.60, 35.07, 35.66, 37.08, 37.12, 37.22, 37.23\ ///
    32.80, 34.81, 36.32, 36.65, 37.15, 38.20, 38.60, 38.70, 38.80, 39.09 ///
    )
    }
  }

  if (eps1 == .15) {

    if (signif == 0.9) {
    cv=( ///
     7.04,8.51, 9.41, 10.04, 10.58, 11.03, 11.43, 11.75, 12.01, 12.20\ /// 
     9.81,11.40, 12.29, 12.90, 13.47, 13.98, 14.36, 14.70, 15.11, 15.28\ ///
    12.08, 13.91, 14.96, 15.68, 16.35, 16.81, 17.24, 17.51, 17.87, 18.12\ ///
    14.26, 16.11, 17.31, 18.00, 18.45, 18.84, 19.22, 19.61, 19.92, 20.07\ ///
    16.14, 18.14, 19.10, 19.84, 20.50, 20.96, 21.42, 21.68, 21.95, 22.28\ ///
    17.97, 20.01, 21.16, 22.08, 22.64, 23.02, 23.35, 23.70, 24.10, 24.37\ ///
    19.70, 21.79, 22.87, 24.06, 24.68, 25.10, 25.66, 25.97, 26.29, 26.50\ ///
    21.41, 23.62, 24.74, 25.63, 26.39, 26.73, 27.29, 27.56, 28.06, 28.46\ ///
    23.06, 25.54, 26.68, 27.60, 28.25, 28.79, 29.19, 29.52, 29.94, 30.43\ ///
    24.65, 26.92, 28.26, 29.18, 29.88, 30.40, 30.90, 31.40, 31.75, 32.03 ///
    )
    }
    if (signif == 0.95) {
    cv=( ///
    8.58, 10.13, 11.14, 11.83, 12.25, 12.66, 13.08, 13.35, 13.75, 13.89\ ///
    11.47, 12.95, 14.03, 14.85, 15.29, 15.80, 16.16, 16.44, 16.77, 16.84\ ///
    13.98, 15.72, 16.83, 17.61, 18.14, 18.74, 19.09, 19.41, 19.68, 19.77\ ///
    16.19, 18.11, 18.93, 19.64, 20.19, 20.54, 21.21, 21.42, 21.72, 21.97\ ///
    18.23, 19.91, 20.99, 21.71, 22.37, 22.77, 23.15, 23.42, 24.04, 24.42\ ///
    20.08, 22.11, 23.04, 23.77, 24.43, 24.75, 24.96, 25.22, 25.61, 25.93\ ///
    21.87, 24.17, 25.13, 26.03, 26.65, 27.06, 27.37, 27.90, 28.18, 28.36\ ///
    23.70, 25.75, 26.81, 27.65, 28.48, 28.80, 29.08, 29.30, 29.50, 29.69\ ///
    25.65, 27.66, 28.91, 29.67, 30.52, 30.96, 31.48, 31.77, 31.94, 32.33\ ///
    27.03, 29.24, 30.45, 31.45, 32.12, 32.50, 32.84, 33.12, 33.22, 33.85 ///
    )
    }
    if (signif == 0.975) {
    cv=( ///
    10.18, 11.86, 12.66, 13.40, 13.89, 14.32, 14.73, 14.89, 15.22, 15.29\ ///
    12.96, 14.92, 15.81, 16.51, 16.84, 17.18, 17.61, 17.84, 18.32, 18.76\ ///
    15.76, 17.70, 18.87, 19.42, 19.77, 20.45, 20.57, 20.82, 21.51, 22.00\ ///
    18.13, 19.70, 20.66, 21.46, 21.97, 22.52, 22.79, 22.82, 23.03, 23.13\ ///
    19.95, 21.72, 22.81, 23.47, 24.42, 24.83, 25.28, 25.59, 25.98, 26.29\ ///
    22.15, 23.79, 24.76, 25.22, 25.93, 26.58, 26.99, 27.11, 27.40, 27.76\ ///
    24.20, 26.03, 27.06, 27.91, 28.36, 28.72, 29.17, 29.43, 29.66, 30.00\ /// 
    25.77, 27.72, 28.80, 29.33, 29.69, 30.02, 30.46, 30.74, 30.90, 31.07\ ///
    27.69, 29.67, 31.00, 31.78, 32.33, 33.06, 33.51, 33.68, 34.16, 34.58\ ///
    29.27, 31.47, 32.54, 33.15, 33.85, 34.32, 34.45, 34.76, 34.94, 35.15 ///
    )
    }
    if (signif == 0.99) {
    cv=( ///
    12.29, 13.89, 14.80, 15.28, 15.76, 16.27, 16.63, 16.77, 16.81, 17.01\ ///
    15.37, 16.84, 17.72, 18.67, 19.17, 19.46, 19.74, 19.93, 20.12, 20.53\ ///
    18.26, 19.77, 20.75, 21.98, 22.46, 22.69, 22.93, 23.11, 23.12, 23.15\ ///
    20.23, 21.97, 22.80, 23.06, 23.76, 24.55, 24.85, 25.11, 25.53, 25.57\ ///
    22.40, 24.42, 25.53, 26.17, 26.53, 26.77, 26.96, 27.10, 27.35, 27.37\ ///
    24.45, 25.93, 27.09, 27.56, 28.20, 29.61, 29.62, 30.27, 30.45, 30.56\ ///
    26.71, 28.36, 29.30, 29.86, 30.52, 30.89, 30.95, 31.03, 31.11, 31.17\ ///
    28.51, 29.69, 30.65, 31.03, 31.87, 32.42, 32.67, 33.00, 33.11, 33.45\ ///
    30.62, 32.33, 33.51, 34.28, 34.94, 35.71, 36.03, 36.34, 36.48, 36.49\ ///
    32.16, 33.85, 34.58, 35.14, 36.15, 36.76, 36.92, 37.37, 37.87, 37.96 ///
    )
    }
  } 


  if (eps1 == .20){

    if (signif == 0.9) {
    cv=( ///
    6.72, 8.13, 9.07, 9.66, 10.17, 10.59, 10.95, 11.28, 11.64, 11.89\ ///
    9.37, 10.92, 11.90, 12.50, 12.89, 13.38, 13.84, 14.15, 14.41, 14.66\ ///
    11.59, 13.43, 14.43, 15.16, 15.72, 16.24, 16.69, 16.95, 17.32, 17.42\ ///
    13.72, 15.59, 16.67, 17.53, 18.17, 18.52, 18.84, 19.12, 19.43, 19.67\ /// 
    15.51, 17.59, 18.76, 19.43, 20.02, 20.53, 20.91, 21.21, 21.59, 21.70\ ///
    17.39, 19.49, 20.65, 21.37, 22.07, 22.57, 22.90, 23.12, 23.38, 23.63\ ///
    19.11, 21.24, 22.42, 23.20, 24.13, 24.68, 25.00, 25.31, 25.76, 26.03\ ///
    20.86, 23.09, 24.30, 25.14, 25.76, 26.27, 26.59, 27.06, 27.41, 27.58\ ///
    22.38, 24.80, 26.10, 26.88, 27.47, 28.05, 28.40, 28.79, 29.16, 29.51\ ///
    23.95, 26.33, 27.50, 28.50, 29.13, 29.52, 30.07, 30.43, 30.87, 31.17 ///
    )
    }
    if (signif == 0.95) {
    cv=( ///
    8.22, 9.71, 10.66, 11.34, 11.93, 12.30, 12.68, 12.92, 13.21, 13.61\ ///
    10.98, 12.55, 13.46, 14.22, 14.78, 15.37, 15.81, 16.13, 16.44, 16.69\ ///
    13.47, 15.25, 16.36, 17.08, 17.51, 18.08, 18.44, 18.89, 19.01, 19.35\ ///
    15.67, 17.61, 18.54, 19.21, 19.80, 20.22, 20.53, 21.06, 21.31, 21.55\ ///
    17.66, 19.50, 20.63, 21.40, 21.72, 22.19, 22.72, 23.01, 23.24, 23.67\ ///
    19.55, 21.44, 22.64, 23.19, 23.75, 24.28, 24.46, 24.75, 24.96, 25.02\ ///
    21.33, 23.31, 24.75, 25.38, 26.10, 26.47, 26.87, 27.15, 27.37, 27.74\ ///
    23.19, 25.23, 26.39, 27.19, 27.63, 28.09, 28.49, 28.70, 28.83, 29.02\ ///
    24.91, 26.92, 28.10, 28.93, 29.64, 30.29, 30.87, 31.09, 31.39, 31.67\ ///
    26.38, 28.56, 29.62, 30.48, 31.23, 31.96, 32.20, 32.38, 32.72, 32.90 ///
    )
    } 
    if (signif == 0.975) {
    cv=( ///
    9.77, 11.34, 12.31, 12.99, 13.61, 13.87, 14.25, 14.37,  14.73, 14.86\ /// 
    12.59, 14.22, 15.39, 16.14, 16.69, 17.00, 17.18, 17.53, 17.65, 17.83\ ///
    15.28, 17.08, 18.10, 18.91, 19.35, 19.70, 20.00, 20.21, 20.53, 20.72\ ///
    17.67, 19.22, 20.25, 21.19, 21.55, 21.88, 22.18, 22.52, 22.77, 22.82\ ///
    19.51, 21.42, 22.28, 23.04, 23.67, 24.20, 24.47, 24.79, 24.94, 25.28\ ///
    21.47, 23.21, 24.28, 24.76, 25.02, 25.70, 26.07, 26.43, 26.73, 26.95\ ///
    23.36, 25.47, 26.47, 27.20, 27.74, 28.21, 28.40, 28.63, 29.09, 29.29\ ///
    25.26, 27.19, 28.10, 28.70, 29.02, 29.41, 29.62, 29.91, 30.11, 30.46\ ///
    26.96, 28.98, 30.34, 31.13, 31.67, 31.89, 32.26, 32.84, 33.14, 33.51\ ///
    28.62, 30.50, 31.97, 32.39, 32.90, 33.20, 33.90, 34.33, 34.53, 34.76 ///
    )
    }
    if (signif == 0.99) {
    cv=( ///
    11.94, 13.61, 14.31, 14.80, 15.26, 15.76, 15.87, 16.23, 16.33, 16.63\ ///
    14.92, 16.69, 17.41, 17.72, 18.27, 19.06, 19.17, 19.23, 19.54, 19.74\ ///
    17.60, 19.35, 20.02, 20.64, 21.23, 21.98, 22.19, 22.54, 22.90, 22.93\ ///
    19.82, 21.55, 22.27, 22.80, 23.06, 23.76, 23.97, 24.55, 24.78, 24.85\ ///
    21.75, 23.67, 24.60, 25.18, 25.76, 26.29, 26.42, 26.53, 26.65, 26.67\ ///
    23.80, 25.02, 26.24, 26.77, 27.27, 27.76, 28.12, 28.48, 28.56, 28.80\ ///
    26.16, 27.74, 28.50, 29.17, 29.66, 30.52, 30.66, 30.89, 30.93, 30.95\ ///
    27.71, 29.02, 29.71, 30.20, 30.78, 31.03, 31.80, 32.42, 32.42, 32.47\ ///
    29.67, 31.67, 32.52, 33.28, 33.81, 34.81, 35.22, 35.54, 35.71, 36.03\ ///
    31.38, 32.90, 34.12, 34.68, 35.00, 36.15, 36.76, 36.92, 37.14, 37.37 ///
    )
    }
  }


  if (eps1 == .25){

    if (signif == 0.9) {
    cv=( ///
    6.35, 7.79, 8.70, 9.22, 9.71, 10.06, 10.45, 10.89, 11.16, 11.30\ ///
    8.96, 10.50, 11.47, 12.13, 12.56, 12.94, 13.29, 13.76, 14.03, 14.22\ ///
    11.17, 12.96, 13.96, 14.58, 15.13, 15.54, 15.93, 16.47, 16.79, 16.96\ /// 
    13.22, 15.16, 16.14, 16.94, 17.52, 17.97, 18.34, 18.67, 18.84, 19.04\ ///
    14.98, 16.98, 18.12, 18.87, 19.47, 19.90, 20.47, 20.74, 21.00, 21.44\ ///
    16.77, 18.88, 20.03, 20.83, 21.41, 21.83, 22.28, 22.58, 22.83, 23.04\ ///
    18.45, 20.69, 21.81, 22.73, 23.49, 24.19, 24.60, 24.87, 25.08, 25.60\ ///
    20.15, 22.51, 23.56, 24.42, 25.11, 25.61, 25.95, 26.43, 26.59, 26.90\ ///
    21.69, 24.08, 25.45, 26.19, 26.79, 27.33, 27.78, 28.23, 28.54, 28.99\ ///
    23.29, 25.72, 26.97, 27.69, 28.55, 29.13, 29.48, 29.90, 30.30, 30.75 ///
    )
    }
    if (signif == 0.95) {
    cv=( ///
    7.86, 9.29, 10.12, 10.93, 11.37, 11.82, 12.20, 12.65, 12.79, 13.09\ ///
    10.55, 12.19, 12.97, 13.84, 14.32, 14.92, 15.28, 15.48, 15.87, 16.34\ /// 
    13.04, 14.65, 15.60, 16.51, 17.08, 17.39, 17.76, 18.08, 18.32, 18.72\ /// 
    15.19, 17.00, 18.10, 18.72, 19.14, 19.63, 20.10, 20.50, 20.98, 21.23\ ///
    17.12, 18.94, 20.02, 20.81, 21.45, 21.72, 22.10, 22.69, 22.98, 23.15\ ///
    18.97, 20.89, 21.92, 22.66, 23.09, 23.42, 23.96, 24.28, 24.46, 24.75\ ///
    20.75, 22.78, 24.24, 24.93, 25.66, 26.03, 26.28, 26.56, 26.87, 27.21\ ///
    22.56, 24.54, 25.71, 26.50, 27.01, 27.51, 27.74, 28.09, 28.48, 28.70\ /// 
    24.18, 26.28, 27.42, 28.27, 29.03, 29.67, 30.34, 30.79, 30.93, 31.13\ /// 
    25.77, 27.75, 29.18, 30.02, 30.83, 31.40, 31.92, 32.20, 32.38, 32.72 ///
    )
    }
    if (signif == 0.975) {
    cv=( ///
    9.32, 10.94, 11.86, 12.66, 13.09, 13.51, 13.85, 14.16, 14.37, 14.70\ ///
    12.21, 13.85, 14.94, 15.48, 16.34, 16.55, 16.80, 16.82, 17.06, 17.34\ ///
    14.66, 16.56, 17.40, 18.12, 18.72, 19.01, 19.40, 19.73, 20.02, 20.50\ ///
    17.04, 18.73, 19.64, 20.52, 21.23, 21.71, 21.95, 22.24, 22.56, 22.79\ ///
    18.96, 20.83, 21.75, 22.69, 23.15, 23.82, 24.20, 24.43, 24.77, 24.83\ ///
    20.93, 22.70, 23.49, 24.35, 24.75, 25.02, 25.58, 25.83, 26.30, 26.68\ ///
    22.85, 24.93, 26.05, 26.66, 27.21, 27.75, 27.99, 28.36, 28.61, 29.09\ /// 
    24.56, 26.51, 27.52, 28.10, 28.70, 29.01, 29.46, 29.69, 29.93, 30.11\ ///
    26.31, 28.28, 29.67, 30.81, 31.13, 31.73, 32.26, 32.84, 33.14, 33.28\ ///
    27.80, 30.07, 31.40, 32.20, 32.72, 33.00, 33.20, 34.02, 34.37, 34.68 ///
    )
    }
    if (signif == 0.99) {
    cv=( ///
     11.44, 13.09, 14.02, 14.63, 14.89, 15.29, 15.76, 16.13, 16.17, 16.23\ ///
     14.34, 16.34, 16.81, 17.18, 17.61, 17.83, 17.85, 18.32, 18.67, 19.06\ ///
     17.08, 18.72, 19.58, 20.45, 20.72, 21.27, 21.98, 22.46, 22.54, 22.57\ ///
     19.22, 21.23, 22.07, 22.61, 22.89, 23.17, 23.77, 23.97, 24.55, 24.78\ ///
     21.51, 23.15, 24.36, 24.82, 25.18, 25.76, 25.98, 26.42, 26.43, 26.53\ ///
     23.12, 24.75, 25.73, 26.58, 26.99, 27.44, 27.56, 28.00, 28.12, 28.56\ ///
     25.67, 27.21, 28.21, 28.80, 29.43, 29.86, 30.38, 30.55, 30.71, 30.89\ ///
     27.10, 28.70, 29.53, 30.02, 30.74, 31.01, 31.80, 32.42, 32.42, 32.47\ ///
     29.12, 31.13, 32.52, 33.25, 33.62, 34.65, 34.81, 35.22, 35.54, 35.71\ ///
     30.86, 32.72, 33.54, 34.58, 34.94, 35.58, 36.15, 36.91, 36.92, 37.14 ///
    )
    }
  }

  crtii = cv[q,l]
  return(crtii)
}
end


cap mata mata drop critval_udwdmax()
mata:
function critval_udwdmax(real scalar eps1 , real scalar signif, real scalar q, string scalar wdmax)
{
  cv=J(10,2,0)

if (strlower(wdmax) == "wdmax") {
  wdmaxi = 2 
}
else {
  wdmaxi = 1
}

if (eps1 ==0.05){

if (signif == 0.9) {
cv=( ///
8.78, 9.14\ ///
11.69,12.33\ ///
14.05,14.76\ ///
16.17,16.95\ ///
17.94,18.85\ ///
19.92,20.89\ ///
21.79,22.81\ ///
23.53,24.55\ ///
25.19,26.40\ ///
26.66,27.79 ///
)
}
if (signif == 0.95) {
cv=( ///
10.17,10.91\ ///
13.27,14.19\ ///
15.80,16.82\ ///
17.88,19.07\ ///
19.74,20.95\ ///
21.90,23.27\ ///
23.77,25.02\ ///
25.51,26.83\ ///
27.28,28.78\ ///
28.75,30.16 ///
)
}
if (signif == 0.975) {
cv=( ///
11.52,12.53\ ///
14.69,16.04\ ///
17.36,18.79\ ///
19.51,20.89\ ///
21.57,23.04\ ///
23.83,25.22\ ///
25.46,26.92\ ///
27.32,28.98\ ///
29.20,30.82\ ///
30.84,32.46 ///
)
}
if (signif == 0.99) {
cv=( ///
13.74,15.02\ ///
16.79,18.11\ ///
19.38,20.81\ ///
21.25,22.81\ ///
24.00,25.46\ ///
26.07,27.63\ ///
28.02,29.57\ ///
29.60,31.32\ ///
31.72,33.32\ ///
33.86,35.47 ///
)
}
}

if (eps1 == .10) {

if (signif == 0.9) {
cv=( ///
8.05,8.63\ ///
10.86,11.71\ ///
13.26,14.14\ ///
15.23,16.27\ ///
17.06,18.14\ ///
19.06,20.22\ ///
20.76,22.03\ ///
22.42,23.71\ ///
24.24,25.66\ ///
25.64,27.05 ///
)
}
if (signif == 0.95) {
cv=( ///
9.52 ,10.39\ ///
12.59,13.66\ ///
14.85,16.07\ ///
17.00,18.38\ ///
18.91,20.3\ ///
21.01,22.55\ ///
22.8,24.34\ ///
24.56,26.1\ ///
26.48,27.99\ ///
27.82,29.46 ///
)
}
if (signif == 0.975) {
cv=( ///
10.83,12.06\ ///
14.15,15.33\ ///
16.64,18.04\ ///
18.75,20.3\ ///
20.68,22.22\ ///
23.25,24.66\ ///
24.75,26.47\ ///
26.54,28.24\ ///
28.33,30.02\ ///
29.9,31.58 ///
)
}
if (signif == 0.99) {
cv=( ///
13.07,14.53\ ///
16.19,17.8\ ///
18.75,20.42\ ///
20.75,22.35\ ///
23.16,24.81\ ///
25.55,27.28\ ///
27.23,28.87\ ///
29.01,30.62\ ///
30.81,32.74\ ///
32.82,34.51 ///
)
}
}

if ( eps1 == 0.15){
if (signif == 0.9) {
cv=( ///
7.46, 8.2\ ///
10.16,11.15\ ///
12.4, 13.58\ ///
14.58, 15.88\ ///
16.49,17.8\ ///
18.23,19.66\ ///
20  ,21.46\ ///
21.7,23.31\ ///
23.38,24.99\ ///
24.9, 26.62 ///
)
}
if (signif == 0.95) {
cv=( ///
8.88,9.91\ ///
11.7,12.81\ ///
14.23,15.59\ ///
16.37,17.83\ ///
18.42,19.96\ ///
20.3,21.86\ ///
22.04,23.81\ ///
23.87,25.63\ ///
25.81,27.53\ ///
27.23,29.06 ///
)
}
if (signif == 0.975) {
cv=( ///
10.39,11.67\ ///
13.18,14.58\ ///
15.87,17.41\ ///
18.24,19.82\ ///
20.1,21.76\ ///
22.27,23.97\ ///
24.26,26.1\ ///
25.88,27.8\ ///
27.78,29.78\ ///
29.36,31.47 ///
)
}
if (signif == 0.99) {
cv=( ///
12.37,13.83\ ///
15.41,17.01\ ///
18.26,19.86\ ///
20.39,21.95\ ///
22.49, 24.5\ ///
24.55,26.68\ ///
26.75,28.76\ ///
28.51,30.4\ ///
30.62,32.71\ ///
32.17, 34.25 ///
)
}
}

if (eps1 == .20){
if (signif == 0.9) {
cv=( ///
6.96,7.67\ ///
9.66,10.46\ ///
11.84,12.79\ ///
13.94,15.05\ ///
15.74,16.8\ ///
17.62,18.76\ ///
19.3,20.56\ ///
21.09,22.45\ ///
22.55,24\ ///
24.17,25.6 ///
)
}
if (signif == 0.95) {
cv=( ///
8.43,9.27\ ///
11.16,12.15\ ///
13.66,14.73\ ///
15.79,17.04\ ///
17.76,19.11\ ///
19.69,21.04\ ///
21.46,22.76\ ///
23.28,24.68\ ///
25.04,26.4\ ///
26.51,28.02 ///
)
}
if (signif == 0.975) {
cv=( ///
9.94,10.93\ ///
12.68,13.87\ ///
15.31,16.65\ ///
17.73,19.12\ ///
19.59,20.84\ ///
21.56, 23.09\ ///
23.4,25.03\ ///
25.31,26.91\ ///
27.02,28.54\ ///
28.67,30.31 ///
)
}
if (signif == 0.99) {
cv=( ///
12.02, 13.16\ ///
14.92,16.52\ ///
17.6,18.89\ ///
19.9,21.27\ ///
21.75,23.39\ ///
23.8,25.17\ ///
26.16,27.71\ ///
27.71,29.3\ ///
29.67,31.67\ ///
31.4,32.99 ///
)
}
}

if (eps1 == .25){
if (signif == 0.9) {
cv=( ///
6.55, 7.09\ ///
9.16,9.8\ ///
11.31,12.01\ ///
13.36,14.16\ ///
15.12,15.93\ ///
16.94,17.92\ ///
18.6,19.61\ ///
20.3,21.38\ ///
21.81,22.81\ ///
23.43,24.43 ///
)
}
if (signif == 0.95) {
cv=( ///
8.01,8.69\ ///
10.67,11.49\ ///
13.15,13.99\ ///
15.28,16.13\ ///
17.14,18.11\ ///
19.1,20.02\ ///
20.84,21.81\ ///
22.62,23.6\ ///
24.28,25.4\ ///
25.8,27.01
)
}
if (signif == 0.975) {
cv=( ///
9.37,10.24\ ///
12.25,13.02\ ///
14.67,15.64\ ///
17.13,18.17\ ///
18.97,19.92\ ///
20.97,22.08\ ///
22.89,24.38\ ///
24.61,25.76\ ///
26.38,27.55\ ///
27.91,29.13 ///
)
}
if (signif == 0.99) {
cv=( ///
11.5,12.27\ ///
14.34, 15.41\ ///
17.08, 18.03\ ///
19.22,20.34\ ///
21.51,22.39\ ///
23.12,24.27\ ///
25.67,26.77\ ///
27.12,28.29\ ///
29.12,30.57\ ///
30.87,32.2
)
}
}

return(cv[q,wdmaxi])

}
end

capture mata mata drop critval_supF()

mata:
function critval_supF(real scalar eps1 , real scalar signif, real scalar l, real scalar q) 
{
cv = J(10,10,0)
if (eps1 == .05) {

if (signif == 0.9) {
cv=( ///
 8.02, 7.87, 7.07, 6.61, 6.14, 5.74, 5.40, 5.09, 4.81\ ///
11.02,10.48, 9.61, 8.99, 8.50, 8.06, 7.66, 7.32, 7.01\ ///
13.43,12.73,11.76,11.04,10.49,10.02, 9.59, 9.21, 8.86\ ///
15.53,14.65,13.63,12.91,12.33,11.79,11.34,10.93,10.55\ ///
17.42,16.45,15.44,14.69,14.05,13.51,13.02,12.59,12.18\ ///
19.38,18.15,17.17,16.39,15.74,15.18,14.63,14.18,13.74\ ///
21.23,19.93,18.75,17.98,17.28,16.69,16.16,15.69,15.24\ ///
22.92,21.56,20.43,19.58,18.84,18.21,17.69,17.19,16.70\ ///
24.75,23.15,21.98,21.12,20.37,19.72,19.13,18.58,18.09\ ///
26.13,24.70,23.48,22.57,21.83,21.16,20.57,20.03,19.55)

}
if (signif == 0.95) {
cv=( ///
 9.63, 8.78, 7.85, 7.21, 6.69, 6.23, 5.86, 5.51, 5.20\ ///
12.89,11.60,10.46, 9.71, 9.12, 8.65, 8.19, 7.79, 7.46\ ///
15.37,13.84,12.64,11.83,11.15,10.61,10.14, 9.71, 9.32\ ///
17.60,15.84,14.63,13.71,12.99,12.42,11.91,11.49,11.04\ ///
19.50,17.60,16.40,15.52,14.79,14.19,13.63,13.16,12.70\ ///
21.59,19.61,18.23,17.27,16.50,15.86,15.29,14.77,14.30\ ///
23.50,21.30,19.83,18.91,18.10,17.43,16.83,16.28,15.79\ ///
25.22,23.03,21.48,20.46,19.66,18.97,18.37,17.80,17.30\ ///
27.08,24.55,23.16,22.08,21.22,20.49,19.90,19.29,18.79\ ///
28.49,26.17,24.59,23.59,22.71,21.93,21.34,20.74,20.17)

}
if (signif == 0.975) {
cv=( ///
11.17, 9.81, 8.52, 7.79, 7.22, 6.70, 6.27, 5.92, 5.56\ ///
14.53,12.64,11.20,10.29, 9.69, 9.10, 8.64, 8.18, 7.80\ ///
17.17,14.91,13.44,12.49,11.75,11.13,10.62,10.14, 9.72\ ///
19.35,16.85,15.44,14.43,13.64,13.01,12.46,11.94,11.49\ ///
21.47,18.75,17.26,16.13,15.40,14.75,14.19,13.66,13.17\ ///
23.73,20.80,19.15,18.07,17.21,16.49,15.84,15.29,14.78\ ///
25.23,22.54,20.85,19.68,18.79,18.03,17.38,16.79,16.31\ ///
27.21,24.20,22.41,21.29,20.39,19.63,18.98,18.34,17.78\ ///
29.13,25.92,24.14,22.97,21.98,21.28,20.59,19.98,19.39\ ///
30.67,27.52,25.69,24.47,23.45,22.71,21.95,21.34,20.79)

}

if (signif == 0.99) {
cv=( ///
13.58,10.95, 9.37, 8.50, 7.85, 7.21, 6.75, 6.33, 5.98\ ///
16.64,13.78,12.06,11.00,10.28, 9.65, 9.11, 8.66, 8.22\ ///
19.25,16.27,14.48,13.40,12.56,11.80,11.22,10.67,10.19\ ///
21.20,18.21,16.43,15.21,14.45,13.70,13.04,12.48,12.02\ ///
23.99,20.18,18.19,17.09,16.14,15.34,14.81,14.26,13.72\ ///
25.95,22.18,20.29,18.93,17.97,17.20,16.54,15.94,15.35\ ///
28.01,24.07,21.89,20.68,19.68,18.81,18.10,17.49,16.96\ ///
29.60,25.66,23.44,22.22,21.22,20.40,19.66,19.03,18.46\ ///
31.66,27.42,25.13,24.01,23.06,22.18,21.35,20.63,19.94\ ///
33.62,29.14,26.90,25.58,24.44,23.49,22.75,22.09,21.47)
}
}


if (eps1 == .10) {

cv=J(10,8,0);
if (signif == 0.9) {
cv=( ///
7.42,6.93,6.09,5.44,4.85,4.32,3.83,3.22\ ///
10.37,9.43,8.48,7.68,7.02,6.37,5.77,4.98\ ///
12.77, 11.61, 10.53,9.69,8.94,8.21,7.49,6.57\ ///
14.81, 13.56, 12.36, 11.43, 10.61,9.86,9.04,8.01\ ///
16.65, 15.32, 14.06, 13.10, 12.20, 11.40, 10.54,9.40\ ///
18.65, 17.01, 15.75, 14.70, 13.78, 12.92, 11.98, 10.80\ /// 
20.34, 18.71, 17.26, 16.19, 15.26, 14.35, 13.40, 12.13\ ///
22.01, 20.32, 18.90, 17.75, 16.79, 15.82, 14.80, 13.45\ ///
23.79, 21.88, 20.43, 19.28, 18.22, 17.24, 16.19, 14.77\ ///
25.29, 23.33, 21.89, 20.71, 19.63, 18.59, 17.50, 16.00 ///
)
}
if (signif == 0.95) {
cv=( ///
 9.10,7.92,6.84,6.03,5.37,4.80,4.23,3.58\ ///
 12.25, 10.58,9.29,8.37,7.62,6.90,6.21,5.41\ ///
 14.60, 12.82, 11.46, 10.41,9.59,8.80,8.01,7.03\ ///
 16.76, 14.72, 13.30, 12.25, 11.29, 10.42,9.58,8.46\ /// 
 18.68, 16.50, 15.07, 13.93, 13.00, 12.10, 11.16,9.96\ ///
 20.76, 18.32, 16.81, 15.67, 14.65, 13.68, 12.63, 11.34\ ///
 22.62, 20.04, 18.45, 17.19, 16.14, 15.11, 14.09, 12.71\ ///
 24.34, 21.69, 20.01, 18.74, 17.66, 16.65, 15.54, 14.07\ ///
 26.20, 23.36, 21.63, 20.32, 19.19, 18.09, 16.89, 15.40\ ///
 27.64, 24.87, 23.11, 21.79, 20.58, 19.47, 18.29, 16.70 ///
)
}
if (signif == 0.975) {
cv=( ///
10.56,8.90,7.55,6.64,5.88,5.22,4.61,3.90\ /// 
13.86, 11.63, 10.14,9.05,8.17,7.40,6.63,5.73\ ///
16.55, 13.90, 12.35, 11.12, 10.19,9.28,8.43,7.40\ ///
18.62, 15.88, 14.22, 12.96, 11.94, 11.05, 10.06,8.93\ /// 
20.59, 17.71, 16.02, 14.68, 13.67, 12.71, 11.68, 10.42\ ///
23.05, 19.69, 17.82, 16.47, 15.31, 14.24, 13.20, 11.89\ ///
24.65, 21.34, 19.41, 18.13, 16.90, 15.84, 14.67, 13.25\ /// 
26.50, 22.98, 20.95, 19.69, 18.52, 17.35, 16.15, 14.67\ /// 
28.25, 24.73, 22.68, 21.29, 20.01, 18.76, 17.56, 16.00\ ///
29.80, 26.37, 24.27, 22.71, 21.42, 20.21, 18.94, 17.33 ///
)
}
if (signif == 0.99) {
cv=( ///
 13.00, 10.14,8.42,7.31,6.48,5.74,5.05,4.28\ ///
 16.19, 12.90, 11.12,9.87,8.84,8.01,7.18,6.18\ /// 
 18.72, 15.38, 13.38, 11.97, 10.93,9.94,8.99,7.85\ ///
 20.75, 17.24, 15.30, 13.93, 12.78, 11.67, 10.64,9.47\ /// 
 23.12, 18.93, 16.91, 15.61, 14.42, 13.31, 12.30, 11.00\ ///
 25.50, 21.15, 19.04, 17.48, 16.19, 15.11, 13.88, 12.55\ /// 
 27.19, 22.97, 20.68, 19.14, 17.81, 16.59, 15.43, 13.92\ /// 
 29.01, 24.51, 22.40, 20.68, 19.41, 18.08, 16.83, 15.30\ ///
 30.81, 26.30, 23.95, 22.33, 20.88, 19.56, 18.35, 16.79\ ///
 32.80, 28.24, 25.63, 23.83, 22.32, 21.04, 19.73, 18.10 ///
)
}
}


if (eps1 == .15) {

cv=J(10,5,0)
if (signif == 0.9) {
cv=( ///
 7.04,6.28,5.21,4.41,3.47\ ///
 9.81,8.63,7.54,6.51,5.27\ ///
12.08, 10.75,9.51,8.29,6.90\ /// 
14.26, 12.60, 11.21,9.97,8.37\ /// 
16.14, 14.37, 12.90, 11.50,9.79\ ///
17.97, 16.02, 14.45, 13.00, 11.19\ /// 
19.70, 17.67, 16.04, 14.55, 12.59\ /// 
21.41, 19.16, 17.47, 15.88, 13.89\ ///
23.06, 20.82, 19.07, 17.38, 15.23\ ///
24.65, 22.26, 20.42, 18.73, 16.54 ///
)
}
if (signif == 0.95) {
cv=( ///
8.58,7.22,5.96,4.99,3.91\ ///
11.47,9.75,8.36,7.19,5.85\ /// 
13.98, 11.99, 10.39,9.05,7.46\ ///
16.19, 13.77, 12.17, 10.79,9.09\ ///
18.23, 15.62, 13.93, 12.38, 10.52\ /// 
20.08, 17.37, 15.58, 13.90, 11.94\ /// 
21.87, 18.98, 17.23, 15.55, 13.40\ ///
23.70, 20.62, 18.69, 16.96, 14.77\ /// 
25.65, 22.35, 20.18, 18.40, 16.11\ /// 
27.03, 23.80, 21.62, 19.79, 17.44 ///
)
}
if (signif == 0.975) {
cv=( ///
10.18,8.14,6.72,5.51,4.34\ /// 
12.96, 10.75,9.15,7.81,6.38\ ///
15.76, 13.13, 11.23,9.72,8.03\ /// 
18.13, 14.99, 13.06, 11.55,9.66\ /// 
19.95, 16.92, 14.98, 13.25, 11.21\ /// 
22.15, 18.62, 16.50, 14.68, 12.63\ /// 
24.20, 20.40, 18.25, 16.41, 14.18\ /// 
25.77, 21.97, 19.71, 17.91, 15.52\ /// 
27.69, 23.68, 21.28, 19.29, 16.88\ /// 
29.27, 24.99, 22.74, 20.81, 18.26
)
}
if (signif == 0.99) { 
cv=( ///
 12.29,9.36,7.60,6.19,4.91\ /// 
 15.37, 12.15, 10.27,8.65,7.00\ /// 
 18.26, 14.45, 12.16, 10.56,8.71\ /// 
 20.23, 16.55, 14.26, 12.42, 10.53\ /// 
 22.40, 18.37, 16.16, 14.25, 12.14\ ///
 24.45, 20.06, 17.57, 15.73, 13.44\ ///
 26.71, 21.87, 19.42, 17.44, 15.02\ ///
 28.51, 23.58, 20.96, 19.00, 16.56\ ///
 30.62, 25.32, 22.72, 20.38, 17.87\ ///
 32.16, 26.82, 24.41, 22.09, 19.27 ///
)
}
}


if (eps1 == .20) {

cv=J(10,3,0)

if (signif == 0.9) {
cv=( ///
6.72,5.59,4.37\ /// 
 9.37,7.91,6.43\ /// 
 11.59,9.93,8.21\ ///
13.72, 11.70,9.90\ /// 
15.51, 13.46, 11.50\ ///
17.39, 15.05, 12.91\ ///
19.11, 16.67, 14.46\ ///
 20.86, 18.16, 15.88\ ///
 22.38, 19.71, 17.30\ /// 
 23.95, 21.13, 18.65 ///
)
}
if (signif == 0.95) {
cv=( ///
8.22,6.53,5.08\ ///
 10.98,8.98,7.13\ ///
13.47, 11.09,9.12\ ///
 15.67, 12.94, 10.78\ ///
17.66, 14.69, 12.45\ /// 
 19.55, 16.35, 13.91\ ///
 21.33, 18.14, 15.55\ /// 
23.19, 19.58, 17.10\ /// 
24.91, 21.23, 18.58\ /// 
 26.38, 22.62, 19.91 ///
)
}
if (signif == 0.975) {
cv=( ///
9.77,7.49,5.73\ ///
12.59, 10.00,7.92\ /// 
 15.28, 12.25,9.91\ ///
17.67, 14.11, 11.66\ /// 
 19.51, 15.96, 13.49\ ///
 21.47, 17.66, 14.97\ /// 
 23.36, 19.41, 16.56\ ///
 25.26, 20.94, 18.03\ /// 
 26.96, 22.69, 19.51\ ///
28.62, 24.04, 20.96 ///
)
}
if (signif == 0.99) {
cv=( ///
 11.94,8.77,6.58\ /// 
 14.92, 11.30,8.95\ ///
 17.60, 13.40, 10.91\ /// 
 19.82, 15.74, 12.99\ ///
 21.75, 17.21, 14.60\ /// 
 23.80, 19.25, 16.29\ ///
 26.16, 21.03, 17.81\ ///
 27.71, 22.71, 19.37\ /// 
 29.67, 24.43, 20.74\ ///
 31.38, 25.73, 22.34 ///
)
}
}

if (eps1 == .25) {

cv=J(10,2,0)

if (signif ==0.9) {
cv=( ///
6.35,4.88\ ///
 8.96,7.06\ /// 
11.17,9.01 \ ///
13.22, 10.74\ ///
14.98, 12.39\ ///
16.77, 13.96\ /// 
18.45, 15.53\ /// 
20.15, 16.91\ ///
21.69, 18.42\ /// 
23.29, 19.84 ///
)
}
if (signif == 0.95) {
cv=( ///
7.86,5.80\ ///
10.55,8.17\ ///
13.04, 10.16\ /// 
15.19, 11.91\ ///
17.12, 13.65\ /// 
18.97, 15.38\ ///
20.75, 16.97\ /// 
22.56, 18.43\ ///
24.18, 19.93\ /// 
25.77, 21.34 ///
)
}
if (signif == 0.975) {
cv=( ///
9.32,6.69\ ///
 12.21,9.16\ /// 
14.66, 11.22\ /// 
17.04, 13.00\ ///
18.96, 14.86\ /// 
20.93, 16.53\ ///
22.85, 18.25\ /// 
24.56, 19.68\ /// 
26.31, 21.38\ /// 
27.80, 22.79 ///
)
}
if (signif == 0.99) {
cv=( ///
 11.44,7.92\ ///
 14.34, 10.30\ ///
 17.08, 12.55\ ///
 19.22, 14.65\ ///
 21.51, 16.18\ ///
 23.12, 18.10\ ///
 25.67, 19.91\ ///
 27.10, 21.41\ ///
 29.12, 23.23\ ///
 30.86, 24.51 ///
)
}
}

res = cv[q,l]
return(res)
}

end