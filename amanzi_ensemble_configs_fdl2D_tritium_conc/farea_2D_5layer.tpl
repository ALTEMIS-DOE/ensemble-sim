<amanzi_input type="unstructured" version="2.3.0">
  <echo_translated_input format="unstructured_native" file_name="oldspec.xml"/>

  <model_description name="Farea 5layer 2D">
    <comments>Example input file</comments>
    <author>Konstantin Lipnikov</author>
    <units>
      <length_unit>m</length_unit>
      <time_unit>s</time_unit>
      <mass_unit>kg</mass_unit>
      <conc_unit>molar</conc_unit>
    </units>
  </model_description>

  <definitions>
    <macros>
      <time_macro name="Phase 1: every two month">
        <start>6.16635504e+10</start>
        <timestep_interval>5.184e+06</timestep_interval>
        <stop>6.2736508e+10</stop>
      </time_macro>
      <time_macro name="every two month">
        <start>6.16635504e+10</start>
        <timestep_interval>5.184e+06</timestep_interval>
        <stop>66225600000</stop>
      </time_macro>
      <time_macro name="Phase 2: every year">
        <start>6.2736508e+10</start>
        <timestep_interval>3.15576e+07</timestep_interval>
        <stop>6.31152e+10</stop>
      </time_macro>
      <time_macro name="Phase 3: every 50 years">
        <start>6.31152e+10</start>
        <timestep_interval>1.57788e+09</timestep_interval>
        <stop>-1</stop>
      </time_macro>
      <cycle_macro name="Every100Cycles">
        <start>0</start>
        <timestep_interval>100</timestep_interval>
      </cycle_macro>
    </macros>
  </definitions>

  <process_kernels>
    <flow model="richards" state="on" />
    <transport state="on" />
    <chemistry engine="amanzi" process_model="none" state="on" input_filename="farea_2D_5layer_tritium.bdg"/>
  </process_kernels>

  <phases>
    <liquid_phase name="water">
      <eos>false</eos>
      <viscosity>1.002E-03</viscosity>
      <density>998.2</density>
      <dissolved_components>
        <solutes>
          <solute coefficient_of_diffusion="0.0">Tritium</solute>
        </solutes>
      </dissolved_components>
    </liquid_phase>
  </phases>

  <geochemistry>
    <amanzi_chemistry>
      <reaction_network file="farea_2D_5layer_tritium.bdg" format="simple"/>
    </amanzi_chemistry>
  </geochemistry>

  <execution_controls>
    <verbosity level="high" />
    <execution_control_defaults init_dt="1.0" method="picard" mode="steady" />
    <execution_control end="1954,y" mode="steady" start="0.0" init_dt="1000.0"/>
    <execution_control end="2100,y" mode="transient" start="1954,y" init_dt="60.0" />
  </execution_controls>

  <numerical_controls>
    <unstructured_controls>
      <unstr_flow_controls>
        <preconditioning_strategy>linearized_operator</preconditioning_strategy>
      </unstr_flow_controls>
      <unstr_transport_controls>
        <algorithm>explicit first-order</algorithm>
        <sub_cycling>on</sub_cycling>
        <cfl>1</cfl>
      </unstr_transport_controls>

      <unstr_steady-state_controls>
        <min_iterations>10</min_iterations>
        <max_iterations>15</max_iterations>
        <limit_iterations>20</limit_iterations>
        <max_preconditioner_lag_iterations>5</max_preconditioner_lag_iterations>
        <nonlinear_tolerance>1.0e-5</nonlinear_tolerance>
        <nonlinear_iteration_damping_factor>1</nonlinear_iteration_damping_factor>
        <nonlinear_iteration_divergence_factor>1000</nonlinear_iteration_divergence_factor>
        <restart_tolerance_relaxation_factor>100.0</restart_tolerance_relaxation_factor>
        <restart_tolerance_relaxation_factor_damping>0.9</restart_tolerance_relaxation_factor_damping>
        <max_divergent_iterations>3</max_divergent_iterations>

        <unstr_initialization>
          <method>darcy_solver</method>
          <linear_solver>aztecoo</linear_solver>
          <clipping_pressure>90000.0</clipping_pressure>
        </unstr_initialization>
      </unstr_steady-state_controls>

      <unstr_transient_controls>
        <min_iterations>10</min_iterations>
        <max_iterations>15</max_iterations>
        <limit_iterations>20</limit_iterations>
        <max_preconditioner_lag_iterations>5</max_preconditioner_lag_iterations>
        <nonlinear_tolerance>1.0e-5</nonlinear_tolerance>
        <nonlinear_iteration_damping_factor>1</nonlinear_iteration_damping_factor>
        <nonlinear_iteration_divergence_factor>1000</nonlinear_iteration_divergence_factor>
        <max_divergent_iterations>3</max_divergent_iterations>
      </unstr_transient_controls>

      <unstr_linear_solver>
        <max_iterations>100</max_iterations>
        <tolerance>1e-20</tolerance>
      </unstr_linear_solver>
      <unstr_preconditioners>
        <hypre_amg />
        <trilinos_ml />
        <block_ilu />
      </unstr_preconditioners>
    </unstructured_controls>
  </numerical_controls>

  <mesh framework="mstk">
    <dimension>2</dimension>
    <read>
      <file>refine_l2_nogordon.exo</file>
      <format>exodus ii</format>
    </read>
  </mesh>

  <regions>
    <region name="Lower aquifer">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="cell" label="30000"/>
    </region>
    <region name="Natural recharge (left)">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="face" label="1"/>
    </region>
    <region name="Natural recharge (right)">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="face" label="3"/>
    </region>
    <region name="Seepage basin">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="face" label="2"/>
    </region>
    <region name="Seepage face">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="face" label="4"/>
    </region>
    <region name="Tan_clay">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="cell" label="40000"/>
    </region>
    <region name="Upper_aquifer">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="cell" label="50000"/>
    </region>
  <region name="UTRA upstream">
      <region_file name="farea_2D_5layer.exo" type="labeled set" format="exodus ii" entity="face" label="8"/>
    </region>
      <point name="Well1" coordinate =  "1866, 46" />
      <point name="Well2" coordinate =  "1866, 47.25" />
      <point name="Well3" coordinate =  "1866, 48.5" />
      <point name="Well4" coordinate =  "1866, 49.75" />
      <point name="Well5" coordinate =  "1866, 51" />
      <point name="Well6" coordinate =  "1866, 57" />
      <point name="Well7" coordinate =  "1866, 58.25" />
      <point name="Well8" coordinate =  "1866, 59.5" />
      <point name="Well9" coordinate =  "1866, 60.75" />
      <point name="Well10" coordinate =  "1866, 62" />
      <point name="Well11" coordinate =  "1866, 63.25" />
      <point name="Well12" coordinate =  "1866, 64.25" />
      <point name="Well13" coordinate =  "2072, 58" />
      <point name="Well14" coordinate =  "2072, 59.25" />
      <point name="Well15" coordinate =  "2072, 60.5" />
      <point name="Well16" coordinate =  "2072, 61.75" />
      <point name="Well17" coordinate =  "2072, 63" />
      <point name="Well18" coordinate =  "2072, 64.25" />
      <point name="Well19" coordinate =  "2072, 65.5" /> 
  </regions>

  <materials>

    <material name="Soil_3: Lower aquifer">
      <mechanical_properties>
        <porosity value="0.39"/>
      </mechanical_properties>
      <permeability x="5.0e-12" z="5.0e-12" />
      <cap_pressure model="van_genuchten">
        <parameters alpha="5.1e-05" m="0.5" sr="0.41" optional_krel_smoothing_interval="500.0"/>
      </cap_pressure>
      <rel_perm model="mualem"/>
      <assigned_regions>Lower aquifer</assigned_regions>
    </material>

    <material name="Soil_4: Tan_clay">
      <mechanical_properties>
        <porosity value="0.39"/>
      </mechanical_properties>
      <permeability x="1.98e-14" z="1.98e-14" />
      <cap_pressure model="van_genuchten">
        <parameters alpha="5.1e-05" m="0.5" sr="0.39" optional_krel_smoothing_interval="500.0"/>
      </cap_pressure>
      <rel_perm model="mualem"/>
      <assigned_regions>Tan_clay</assigned_regions>
    </material>

    <material name="Soil_5: Upper_aquifer">
      <mechanical_properties>
        <porosity value="@Por@"/>
      </mechanical_properties>
      <permeability x="@Perm@" z="@Perm@" />
      <cap_pressure model="van_genuchten">
        <parameters alpha="@alpha@" m="@m@" sr="@sr@" optional_krel_smoothing_interval="500.0"/>
      </cap_pressure>
      <rel_perm model="mualem"/>
      <assigned_regions>Upper_aquifer</assigned_regions>
    </material>
  </materials>

  <initial_conditions>
    <initial_condition name="All">
      <assigned_regions>All</assigned_regions>
      <liquid_phase name="water">
        <liquid_component name="water">
          <linear_pressure name="IC1" value="101325.0" reference_coord="0.0, 60.0" gradient="0,-9793.5192" />
        </liquid_component>
        <solute_component>
          <uniform_conc name="Tritium" value="1.0e-50" function="constant" start="0.0"/>
        </solute_component> 
      </liquid_phase>
    </initial_condition>
  </initial_conditions>

  <boundary_conditions>
    <comments/>
    <boundary_condition name="BC 1: Seepage Face">
      <assigned_regions>Seepage face,Natural recharge (right)</assigned_regions>
      <liquid_phase name="water">
        <liquid_component name="water">
          <seepage_face function="uniform" start="0.0" inward_mass_flux="@Rech_hist@"/>
          <seepage_face function="constant" start="63702720000" inward_mass_flux="@Rech_mid@"/>
          <seepage_face function="constant" start="63734276736" inward_mass_flux="@Rech_late@"/>
        </liquid_component>
      </liquid_phase>
    </boundary_condition>

    <boundary_condition name="BC 2: Mass Flux">
      <assigned_regions>Natural recharge (left)</assigned_regions>
      <liquid_phase name="water">
        <liquid_component name="water">
          <inward_mass_flux value="@Rech_hist@" function="constant" start="0.0" />
          <inward_mass_flux value="@Rech_mid@" function="constant" start="63702720000" />
          <inward_mass_flux value="@Rech_late@" function="constant" start="63734276736" />
        </liquid_component>
        <solute_component>
          <aqueous_conc name="Tritium" value="0.0" function="constant" start="0.0"/>
        </solute_component> 
      </liquid_phase>
    </boundary_condition>

    <boundary_condition name="BC 3: Mass Flux">
      <assigned_regions>Seepage basin</assigned_regions>
      <liquid_phase name="water">
        <liquid_component name="water">
          <inward_mass_flux value="4.743e-06" function="constant" start="0.0" />
          <inward_mass_flux value="@seepage@" function="constant" start="6.16635504e+10" />
          <inward_mass_flux value="4.743e-09" function="constant" start="6.27365088e+10" />
        </liquid_component>
        <solute_component>
          <aqueous_conc name="Tritium" value="0.0" function="constant" start="0.0"/>
          <aqueous_conc name="Tritium" value="2.17e-09" function="constant" start="6.16635504e+10"/>
          <aqueous_conc name="Tritium" value="0.0" function="constant" start="6.27365088e+10"/>
       </solute_component> 
      </liquid_phase>
    </boundary_condition>

   <!-- <boundary_condition name="BC 4: Hydrostatic">
      <assigned_regions>UTRA upstream</assigned_regions>
      <liquid_phase name="water">
        <liquid_component name="water">
          <hydrostatic value="70.0869" function="constant" start="0.0" />
        </liquid_component>
        <solute_component>
          <aqueous_conc name="Tritium" value="0.0" function="constant" start="0.0"/>
       </solute_component> 
      </liquid_phase>
    </boundary_condition>-->
  </boundary_conditions>

  <output> 
       <observations>
       <filename>observation1.out</filename>
        <liquid_phase name="water">
          <aqueous_conc solute="Tritium">
            <assigned_regions>Well1</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well2</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well3</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well4</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well5</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well6</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
            <aqueous_conc solute="Tritium">
            <assigned_regions>Well7</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well8</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well9</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well10</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
          <aqueous_conc solute="Tritium">
            <assigned_regions>Well11</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well12</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well13</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
          <aqueous_conc solute="Tritium">
           <assigned_regions>Well14</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well15</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well16</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well17</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
          <aqueous_conc solute="Tritium">
            <assigned_regions>Well18</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
           <aqueous_conc solute="Tritium">
            <assigned_regions>Well19</assigned_regions>
            <functional>point</functional>
            <time_macros>every two month</time_macros>
          </aqueous_conc>
          <solute_volumetric_flow_rate solute="Tritium">
            <assigned_regions>Seepage face</assigned_regions>
            <functional>integral</functional>
            <time_macros>every two month</time_macros>
          </solute_volumetric_flow_rate>
        </liquid_phase>
      </observations>
    <vis>
      <base_filename>plot</base_filename>
      <num_digits>5</num_digits>
      <cycle_macros>every two month</cycle_macros>
    </vis>
<!--     <checkpoint>
      <base_filename>chk</base_filename>
      <num_digits>5</num_digits>
      <cycle_macros>Every100Cycles</cycle_macros>
    </checkpoint> -->
  </output>
</amanzi_input>
  

