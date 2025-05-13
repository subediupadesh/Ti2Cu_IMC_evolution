### By Upadesh Subedi 28th Nov 2023  


## Geometry changed for eta 2,3,4 from v1
## Geometry and Mesh increased from v3
## eta 5 added
## Dimension changed from v4


[Mesh] 
  type = GeneratedMesh
  dim = 2
  nx = 250 #250
  ny = 250 #250
  nz = 0
  xmin = 0
  xmax = 500
  ymin = 0
  ymax = 500
  zmin = 0
  zmax = 0
  elem_type = QUAD9
[]

[ICs]

    [eta2]
        variable = eta2
        type = FunctionIC
        function = 'if(y>300&y<=400 & x>200&x<=300, 1, 0)'
    []

    [eta3]
        variable = eta3
        type = FunctionIC
        function = 'if(y>230&y<=300 & x>150&x<=200, 1, 0)'
    []

    [eta4]
        variable = eta4
        type = FunctionIC
        function = 'if(y>230&y<=300  & x>300&x<=470, 1, 0)'
    []

    [eta5]
        variable = eta5
        type = FunctionIC
        function = 'if(y>65&y<=230  & x>200&x<=300, 1, 0)'
    []


    [eta1]
        variable = eta1
        type = FunctionIC
        function = 'if(y>300&y<=400 & x>200&x<=300, 0,
                    if(y>230&y<=300 & x>150&x<=200, 0,
                    if(y>230&y<=300 & x>300&x<=470, 0,
                    if(y>65&y<=230  & x>200&x<=300, 0, 1))))'
    []

    [c]
        variable = c
        type = FunctionIC
        function =  '0.033* if(y>300&y<=400 & x>200&x<=300, 1,
                            if(y>230&y<=300 & x>150&x<=200, 1,
                            if(y>230&y<=300 & x>300&x<=470, 1,
                            if(y>65&y<=230  & x>200&x<=300, 1, 0))))
                    + 0.08* if(y>300&y<=400 & x>200&x<=300, 0,
                            if(y>230&y<=300 & x>150&x<=200, 0,
                            if(y>230&y<=300 & x>300&x<=470, 0,
                            if(y>65&y<=230  & x>200&x<=300, 0, 1))))' 
    []

[]

[BCs]

    # [temp_fixed]
    #     type = ADDirichletBC
    #     variable = temp
    #     boundary = 'bottom'
    #     value = 300
    # []

    [Periodic]
        [all]
          auto_direction = 'x'
          variable = 'eta1 eta2 eta3 eta4 eta5 c c1 c2 w' 
        []
    []
[]

[AuxVariables]

    [Energy]
        order = CONSTANT
        family = MONOMIAL
    []

    [bnds]
    []

    [gr_c]
        order = CONSTANT
        family = MONOMIAL
    []
[]


[Variables]

    # [temp]
    #     scaling = 1.0e-10
    #     initial_condition = 300 #700
    # []

     # potential variable used in SplitCHCRes and kkssplitchcres (global)
    [w]
        order = FIRST
        family = LAGRANGE
        scaling = 1e-10
    []

     # concentration (global)
    [c]
        order = FIRST
        family = LAGRANGE
        scaling = 1e-7
    []

    [c1]
        order = FIRST
        family = LAGRANGE
        scaling =1e-8
    []

    [c2]
        order = FIRST
        family = LAGRANGE
        scaling =1e-10
    []

    [eta1]
        order = FIRST
        family = LAGRANGE
        scaling = 1e-2
    []

    [eta2]
        order = FIRST
        family = LAGRANGE
        scaling = 1e-2
    []

    [eta3]
        order = FIRST
        family = LAGRANGE
        scaling = 1e-2
    []

    [eta4]
        order = FIRST
        family = LAGRANGE
        scaling = 1e-2
    []

    [eta5]
        order = FIRST
        family = LAGRANGE
        scaling = 1e-2
    []

[]

# [Functions]

#     [path_x]
#         type = ParsedFunction
#         value = 125+5.0e-4*t
#     []

#     [path_y]
#         type = ParsedFunction  
#         value = 500
#     []

#     [path_z]
#         type = ParsedFunction
#         value = 0
#     []

# []

[Materials]

    [scale] # m-->nm J-->eV s-->10ms v_mol-->m^3/mol (Cu-> 7.11e-6m^3/mol ; Ti->10.64e-6 m^3/mol)
        type = GenericConstantMaterial
        prop_names = 'length_scale energy_scale time_scale v_mol'
        prop_values = '1e9 6.24150943e18 1e7 7.11e-6'
    []


    [f1] # For Ti rich phase
        type = DerivativeParsedMaterial
        f_name = F1
        material_property_names = 'length_scale energy_scale v_mol'
        constant_names = 'factor_f1 A1 B1 C1 D1 xe1 '
        constant_expressions = '-14950.7 -3.1 -2.5 3.6 3.7 0.7015'
        args = 'c1'
        function = 'factor_f1*(A1*(D1*c1 - xe1)^2 + B1*(D1*c1 - xe1) + C1)*energy_scale/(v_mol*length_scale^3)'
    []

    [f2] # CuTi2  (IMC) rich phase
        type = DerivativeParsedMaterial
        f_name = F2
        material_property_names = 'length_scale energy_scale v_mol'
        constant_names = 'factor_f2 A2 B2 C2 D2 xe2'
        constant_expressions = '-19006 -295 -2.5 3.6 3.7 1.22526'
        args = 'c2'
        function = 'factor_f2*(A2*(D2*c2 - xe2)^2 + B2*(D2*c2 - xe2) + C2)*energy_scale/(v_mol*length_scale^3)'
    []


     #Switching Functions        ## Eq 10,11 of https://doi.org/10.1016/j.actamat.2010.10.038 A quantitative and thermodynamically Moelans 2011
    [h1]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = h1
        all_etas = 'eta1 eta2 eta3 eta4 eta5'
        phase_etas = eta1
    []

    [h2]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = h2
        all_etas = 'eta1 eta2 eta3 eta4 eta5'
        phase_etas = eta2
    []

    [h3]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = h3
        all_etas = 'eta1 eta2 eta3 eta4 eta5'
        phase_etas = eta3
    []

    [h4]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = h4
        all_etas = 'eta1 eta2 eta3 eta4 eta5'
        phase_etas = eta4
    []

    [h5]
        type = SwitchingFunctionMultiPhaseMaterial
        h_name = h5
        all_etas = 'eta1 eta2 eta3 eta4 eta5'
        phase_etas = eta5
    []

     # Barrier functions for each phase
    [g1]
        type = BarrierFunctionMaterial
        g_order = SIMPLE
        eta = eta1
        function_name = g1
    []

    [g2]
        type = BarrierFunctionMaterial
        g_order = SIMPLE
        eta = eta2
        function_name = g2
    []

    [g3]
        type = BarrierFunctionMaterial
        g_order = SIMPLE
        eta = eta3
        function_name = g3
    []

    [g4]
        type = BarrierFunctionMaterial
        g_order = SIMPLE
        eta = eta4
        function_name = g4
    []

    [g5]
        type = BarrierFunctionMaterial
        g_order = SIMPLE
        eta = eta5
        function_name = g5
    []

    [constants]
        type = GenericConstantMaterial
        prop_names = 'sigma delta gamma M1 M2 M3 M4 R'
        # prop_names  = 'sigma delta  gamma M_pseudo1  M_pseudo2  M_pseudo3 M_pseudo4 R' 
        prop_values = '15.0  10.0e-9  1.5  2.0e-8   2.0e-8    2.0e-8      2.0e-8   8.31' #sigma -> J/m^2; delta -> meter; M_si unit-> m^5/Js #25.0e-9
    []
    
    [mu]
        type = ParsedMaterial
        f_name = mu
        material_property_names = 'sigma delta energy_scale length_scale'
        function = '6*(sigma/delta)*(energy_scale/length_scale^3)' 
    []
    
    [kappa]
        type = ParsedMaterial
        f_name = kappa
        material_property_names = 'sigma delta energy_scale length_scale'
        function = '0.75*(sigma*delta)*(energy_scale/length_scale)' 
    []


    #  ## Note: All M1... should be in SI unit to avoid double scaling
    # [M1] # http://arfc.github.io/software/moltres/wiki/input_example/  # exponential function for temp dep.
    #     type = DerivativeParsedMaterial
    #     f_name = M1
    #     material_property_names = 'R'
    #     constant_names = 'fos1 F_M1 F_temp M_1 Q_1 temp'
    #     constant_expressions = '0 1.0 1.0 1.29e-06 6378 1250'
    #     # args = 'temp'
    #     function = 'fos1+F_M1*F_temp*M_1*exp(-Q_1/(R*temp))'  ## Eqn 9 of https://www.sciencedirect.com/science/article/pii/S0026271417305449#s0010
    # []

    # [M2]
    #     type = DerivativeParsedMaterial
    #     f_name = M2
    #     material_property_names = 'R'
    #     constant_names = 'fos2 F_M2 F_temp M_2 Q_2 temp'
    #     # constant_expressions = '0 1.0 1.0 2.26e-06 2150 1250'
    #     constant_expressions = '0 1.0 1.0 2.26e-06 2150'
    #     args = 'temp'
    #     function = 'fos2+F_M2*F_temp*M_2*exp(-Q_2/(R*temp))'
    # []

    # [M3]
    #     type = DerivativeParsedMaterial
    #     f_name = M3
    #     material_property_names = 'R'
    #     constant_names = 'fos3 F_M3 F_temp M_3 Q_3'
    #     constant_expressions = '0 1.0 1.0 2.26e-06 2150'
    #     args = 'temp'
    #     function = 'fos3+F_M3*F_temp*M_3*exp(-Q_3/(R*temp))'
    # []

    # [M4]
    #     type = DerivativeParsedMaterial
    #     f_name = M4
    #     material_property_names = 'R'
    #     constant_names = 'fos4 F_M4 F_temp M_4 Q_4'
    #     constant_expressions = '0 1.0 1.0 2.26e-06 2150'
    #     args = 'temp'
    #     function = 'fos4+F_M4*F_temp*M_4*exp(-Q_4/(R*temp))'
    # []

    [Mobility]
        type = ParsedMaterial
        f_name = M
        material_property_names = 'length_scale energy_scale time_scale M1 M2 M3 M4 M_gb h1 h2 h3 h4 h5'
        function = '(h1*M1 + (h2+h3+h4+h5)*M2 + (h2+h3+h4+h5)*(h2+h3+h4+h5)*M_gb) * (length_scale^5/(time_scale*energy_scale))'
    []

    [M_grain_bound]
        type = ParsedMaterial
        material_property_names = 'M2' # M2-->IMC_grain
        f_name = M_gb
        function = '100*M2'
    []

    [L1-2]
        type = ParsedMaterial
        f_name = L1_2 
        constant_names = 'factor_L'
        constant_expressions = '1.0'
        material_property_names = 'M1 M2 energy_scale time_scale length_scale mu kappa'
        function = 'factor_L*(0.5/0.2)*(M1+M2)*(mu/kappa)*(length_scale^3/(time_scale*energy_scale))'  ## 0.2 ==> total values of dinominator of Eq 21 ( here we don't know ci,eq,i/j/k values) so 0.2 is taken as whole 
    []

    [L2-3]
        type = ParsedMaterial
        f_name = L2_3
        constant_names = 'factor_L'
        constant_expressions = '1.0'
        material_property_names = 'M2 M_gb energy_scale time_scale length_scale mu kappa h2 h3 h4 h5'
        function = 'factor_L*((0.5/0.2)*(M2+M2)+M_gb*(h2*h3+h2*h4+h2*h5+h3*h4+h3*h5+h4*h5))*(mu/kappa)*(length_scale^3/(time_scale*energy_scale))' 
    []

    [Interface_Mobility]
        type = ParsedMaterial
        f_name = L
        args = 'eta1 eta2 eta3 eta4 eta5'
        material_property_names = 'L1_2 L2_3 h1 h2 h3 h4 h5'
        function = '(L1_2*(h1*h2+h1*h3+h1*h4+h1*h5)
                    +L2_3*(h2*h3+h2*h4+h2*h5+h3*h4+h3*h5+h4*h5))'
    []
[]

[Kernels]
   
     # Phase concentration constraints
    [chempot12]
        type = KKSPhaseChemicalPotential
        variable = c1
        cb = c2
        fa_name = F1
        fb_name = F2
        # args_a = temp
    []

    # [chempot23]
    #     type = KKSPhaseChemicalPotential
    #     variable = c2
    #     cb       = c3
    #     fa_name  = F2
    #     fb_name  = F3
    #     args_a = temp
    # []

    # [chempot34]
    #     type = KKSPhaseChemicalPotential
    #     variable = c3
    #     cb       = c4
    #     fa_name  = F3
    #     fb_name  = F4
    #     args_a = temp
    # []
    
    # [chempot41]
    #     type = KKSPhaseChemicalPotential
    #     variable = c4
    #     cb       = c1
    #     fa_name  = F4   ## If kept F1 instead then residual of c4 is 0 that is error
    #     fb_name  = F1
    #     args_a = temp
    # []

    [phaseconcentration]
        type = KKSMultiPhaseConcentration
        variable = c2
        cj = 'c1 c2 c2 c2 c2'
        hj_names = 'h1 h2 h3 h4 h5'
        etas = 'eta1 eta2 eta3 eta4 eta5'
        c = c
    []

     ## Kernels for split Cahn-Hilliard type equation
       ## CHBulk known as KKSSplitCHCRes is here to replace SplitCHParsed
       ## because in KKS model , gradient energy term is not allowed in the C-H type equation [Tonks2018-ComputationalMaterialsScience,vol. 147, pp.353-362.]
       ## while SplitCHParsed kernel consists of the term k\nabla^2 c_i (thus making it unsuitable here), KKSSplitCHCRes fortunately avoids this term.
       ## Never use SplitCHParsed kernel with KKS model
       ## Because of the KKS condition 1 (equality of chemical potential between any two adjacent phases), one KKSSplitCHCRes kernel (either for c1, c2 or c3) is sufficient and there is no need to put three such kernels corresponding to c1, c2 and c3.

    [CHBulk] # Gives the residual for the concentration, dF/dc-mu
        type = KKSSplitCHCRes
        # args_a = temp
        variable = c
        ca = c2       # Why only c2? coz of KKS condition equality of chem pot between phases. & only F2 is used
        fa_name = F2
        w = w
    []

    [dcdt] # Gives dc/dt
        type = CoupledTimeDerivative
        variable = w
        v = c
    []

    [ckernel] # Gives residual for chemical potential dc/dt+M\grad(mu)
        type = SplitCHWRes
        mob_name = M
        variable = w
        args = 'eta1 eta2 eta3 eta4 eta5'
    []

   # Kernels for Allen-Cahn equation for eta1
    [deta1dt]
        type = TimeDerivative
        variable = eta1
    []

    [ACBulkF1]
        type = KKSMultiACBulkF
        variable = eta1
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        gi_name = g1
        eta_i = eta1
        wi = 1.0
        args = 'c1 c2 eta2 eta3 eta4 eta5'
        mob_name = L
    []

    [ACBulkC1]
        type = KKSMultiACBulkC
        variable = eta1
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        cj_names = 'c1 c2 c2 c2 c2'
        eta_i = eta1
        args = 'eta2 eta3 eta4 eta5'
        mob_name = L
    []

    [ACInterface1]
        type = ACInterface
        variable = eta1
        kappa_name = kappa
        mob_name = L
    []

    [ACdfintdeta1] #L*m*(eta_i^3-eta_i+2*beta*eta_i*sum_j eta_j^2)
        type = ACGrGrMulti
        variable = eta1
        v = 'eta2 eta3 eta4 eta5'
        gamma_names = 'gamma gamma gamma gamma'
        mob_name = L
        args = 'eta2 eta3 eta4 eta5'
    []

   # Kernels for Allen-Cahn equation for eta2
    [deta2dt]
        type = TimeDerivative
        variable = eta2
    []

    [ACBulkF2]
        type = KKSMultiACBulkF
        variable = eta2
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        gi_name = g2
        eta_i = eta2
        wi = 1.0
        args = 'c1 c2 eta1 eta3 eta4 eta5'
        mob_name = L
    []

    [ACBulkC2]
        type = KKSMultiACBulkC
        variable = eta2
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        cj_names = 'c1 c2 c2 c2 c2'
        eta_i = eta2
        args = 'eta1 eta3 eta4 eta5'
        mob_name = L
    []

    [ACInterface2]
        type = ACInterface
        variable = eta2
        kappa_name = kappa
        mob_name = L
    []

    [ACdfintdeta2]
        type = ACGrGrMulti
        variable = eta2
        v = 'eta1 eta3 eta4 eta5'
        gamma_names = 'gamma gamma gamma gamma'
        mob_name = L
        args = 'eta1 eta3 eta4 eta5'
    []

   # Kernels for Allen-Cahn equation for eta3
    [deta3dt]
        type = TimeDerivative
        variable = eta3
    []

    [ACBulkF3]
        type = KKSMultiACBulkF
        variable = eta3
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        gi_name = g3
        eta_i = eta3
        wi = 1.0
        args = 'c1 c2 eta1 eta2 eta4 eta5'
        mob_name = L
    []

    [ACBulkC3]
        type = KKSMultiACBulkC
        variable = eta3
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        cj_names = 'c1 c2 c2 c2 c2'
        eta_i = eta3
        args = 'eta1 eta2 eta4 eta5'
        mob_name = L
    []

    [ACInterface3]
        type = ACInterface
        variable = eta3
        kappa_name = kappa
        mob_name = L
    []

    [ACdfintdeta3]
        type = ACGrGrMulti
        variable = eta3
        v = 'eta1 eta2 eta4 eta5'
        gamma_names = 'gamma gamma gamma gamma'
        mob_name = L
        args = 'eta1 eta2 eta4 eta5'
    []

   # Kernels for Allen-Cahn equation for eta4
    [deta4dt]
        type = TimeDerivative
        variable = eta4
    []

    [ACBulkF4]
        type = KKSMultiACBulkF
        variable = eta4
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        gi_name = g4
        eta_i = eta4
        wi = 1.0
        args = 'c1 c2 eta1 eta2 eta3 eta5'
        mob_name = L
    []

    [ACBulkC4]
        type = KKSMultiACBulkC
        variable = eta4
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        cj_names = 'c1 c2 c2 c2 c2'
        eta_i = eta4
        args = 'eta1 eta2 eta3 eta5'
        mob_name = L
    []

    [ACInterface4]
        type = ACInterface
        variable = eta4
        kappa_name = kappa
        mob_name = L
    []

    [ACdfintdeta4]
        type = ACGrGrMulti
        variable = eta4
        v = 'eta1 eta2 eta3 eta5'
        gamma_names = 'gamma gamma gamma gamma'
        mob_name = L
        args = 'eta1 eta2 eta3 eta5'
    []    
    
   # Kernels for Allen-Cahn equation for eta5
    [deta5dt]
        type = TimeDerivative
        variable = eta5
    []

    [ACBulkF5]
        type = KKSMultiACBulkF
        variable = eta5
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        gi_name = g5
        eta_i = eta5
        wi = 1.0
        args = 'c1 c2 eta1 eta2 eta3 eta4'
        mob_name = L
    []

    [ACBulkC5]
        type = KKSMultiACBulkC
        variable = eta5
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        cj_names = 'c1 c2 c2 c2 c2'
        eta_i = eta5
        args = 'eta1 eta2 eta3 eta4'
        mob_name = L
    []

    [ACInterface5]
        type = ACInterface
        variable = eta5
        kappa_name = kappa
        mob_name = L
    []

    [ACdfintdeta5]
        type = ACGrGrMulti
        variable = eta5
        v = 'eta1 eta2 eta3 eta4'
        gamma_names = 'gamma gamma gamma gamma'
        mob_name = L
        args = 'eta1 eta2 eta3 eta4'
    []    
[]


[AuxKernels]
    [Energy_total]
        type = KKSMultiFreeEnergy
        Fj_names = 'F1 F2 F2 F2 F2'
        hj_names = 'h1 h2 h3 h4 h5'
        gj_names = 'g1 g2 g3 g4 g5'
        variable = Energy
        w = 1
        interfacial_vars = 'eta1 eta2 eta3 eta4 eta5'
        kappa_names = 'kappa kappa kappa kappa kappa'
    []

    [bnds]
        type = BndsCalcAux
        variable = bnds
        var_name_base = eta
        op_num = 5
        v = 'eta1 eta2 eta3 eta4 eta5'
    []

    [sumCdothsquare]
        type = FivePhasesSumCdothsquare
        variable = gr_c
        var1=c
        h1_name = h1
        h2_name = h2
        h3_name = h3
        h4_name = h4
        h5_name = h5
      []
[]

[Executioner]
    type = Transient
    solve_type = 'PJFNK'
  # petsc_options_iname = '-pc_type -sub_pc_type   -sub_pc_factor_shift_type'
  # petsc_options_value = 'asm       ilu            nonzero'
    petsc_options = '-snes_converged_reason -ksp_converged_reason -options_left'
    petsc_options_iname = '-ksp_gmres_restart -pc_factor_shift_type -pc_factor_shift_amount -pc_type'
    petsc_options_value = '100 NONZERO 1e-15 ilu'  
    l_max_its = 30
    nl_max_its = 50
    l_tol = 1e-04
    nl_rel_tol = 1e-08
    nl_abs_tol = 1e-09

    end_time = 5.0e+07
    dt = 2.5e+04

    # [Adaptivity]
    #     initial_adaptivity = 1
    #     refine_fraction = 0.7
    #     coarsen_fraction = 0.1
    #     max_h_level = 1
    #     weight_names = 'eta1 eta2 eta3 eta4 eta5'
    #     weight_values = '1 1 1 1 1'
    # []

    # [TimeStepper]
    #     type = IterationAdaptiveDT
    #     dt = 2.5e+04
    #     cutback_factor = 0.8
    #     growth_factor = 1.5 
    #     optimal_iterations = 7
    #     # num_steps = 55
    #     # end_time = 1.0e+10
    # []
[]

[Preconditioning]
    active = 'full'

    [full]
        type = SMP
        full = true
    []

    [mydebug]
        type = FDP
        full = true
    []
[]

[Postprocessors]
    # [total_energy]
    #   type = ElementIntegralVariablePostprocessor
    #   variable = f_density
    #   execute_on = 'Initial TIMESTEP_END'
    # []
    
   # Area of Phases
    [area_h1]
        type = ElementIntegralMaterialProperty
        mat_prop = h1
        execute_on = 'Initial TIMESTEP_END'
    []
  
    [area_h2]
        type = ElementIntegralMaterialProperty
        mat_prop = h2
        execute_on = 'Initial TIMESTEP_END'
    []
  
    [area_h3]
        type = ElementIntegralMaterialProperty
        mat_prop = h3
        execute_on = 'Initial TIMESTEP_END'
    []
  
    [area_h4]
        type = ElementIntegralMaterialProperty
        mat_prop = h4
        execute_on = 'Initial TIMESTEP_END'
    []

    [area_h5]
        type = ElementIntegralMaterialProperty
        mat_prop = h5
        execute_on = 'Initial TIMESTEP_END'
    []

  []

[Outputs]
    exodus = true
    interval = 1
    file_base = exodus/5
    csv = true
    [my_checkpoint]
        type = Checkpoint
        num_files = 2
        interval = 2
        file_base = exodus/5
    []
[]

[Debug]
    show_var_residual_norms = true
[]
