with Numerics, Numerics.Sparse_Matrices, Chebyshev, Ada.Text_IO;
use  Numerics, Numerics.Sparse_Matrices, Chebyshev, Ada.Text_IO;
generic
   K    : in Nat;
package Dense_AD.Integrator is
   
   type Dense_Or_Sparse is (Dense, Sparse);
   
   type Variable is record
      X : Vector;
      T : Real;
   end record;
   
   type Control_Type is record
      Dt  : Real := 1.0;
      Dtn : Real := 1.0;
      Eps : Real := 1.0e-10;
      Err : Real := 1.0;
   end record;
   
   
   type Array_Of_Vectors is array (1 .. N) of Real_Vector (1 .. K);
   
   function Chebyshev_Transform (Y : in Real_Vector) return Array_Of_Vectors
     with Pre => Y'First = 1 and Y'Length = N * K;
   
   
   function Interpolate (A : in Array_Of_Vectors;
			 T : in Real;
			 L : in Real;
			 R : in Real) return Vector;
   
   procedure Update (Var : in out Variable;
		     Y	 : in     Real_Vector;
		     Dt	 : in     Real)
     with Pre => Y'First = 1 and Y'Length = N * K;
   
   function Update (Lagrangian : not null access 
		      function (X : Vector) return AD_Type;
		    Var        : in     Variable;
		    Control    : in out Control_Type;
		    Density    : in Dense_Or_Sparse) return Real_Vector;
      
   procedure Print_Lagrangian (File	  : in     File_Type;
			       Var	  : in     Variable;
			       Lagrangian : not null access
				 function (X : Vector) return AD_Type;
			       Fore : in Field := 3;
			       Aft  : in Field := 5;
			       Exp  : in Field := 3);
   
   procedure Print_Lagrangian (Var	  : in     Variable;
			       Lagrangian : not null access
				 function (X : Vector) return AD_Type;
			       Fore : in Field := 3;
			       Aft  : in Field := 5;
			       Exp  : in Field := 3);
   
   
   
private

   Collocation_Density : Dense_Or_Sparse := Sparse;
   
   function Split (Y : in Real_Vector) return Array_Of_Vectors
     with Pre => Y'First = 1 and Y'Length = N * K;
   
   procedure Iterate (Lagrangian : not null access 
			function (X : Vector) return AD_Type;
		      Y          : in out Real_Vector;
		      Var        : in     Variable;
		      Control    : in out Control_Type);
   
   procedure Colloc (Lagrangian : not null access 
			  function (X : Vector) return AD_Type;
			Q          : in out Real_Vector;
			Var        : in     Variable;
			Control    : in out Control_Type);
   
   procedure Collocation (Lagrangian : not null access 
			    function (X : Vector) return AD_Type;
			  Q          : in out Real_Vector;
			  Var        : in     Variable;
			  Control    : in out Control_Type);
   procedure FJ (Lagrangian : not null access 
		    function (X : Vector) return AD_Type;
		  Var     : in     Variable;
		  Control : in     Control_Type;
		  Q       : in     Real_Vector;
		  F       :    out Real_Vector;
		  J       :    out Real_Matrix);
   
   procedure Sp_Collocation (Lagrangian : not null access 
			       function (X : Vector) return AD_Type;
			     Q          : in out Real_Vector;
			     Var        : in     Variable;
			     Control    : in out Control_Type);
   procedure Sp_FJ (Lagrangian : not null access 
		      function (X : Vector) return AD_Type;
		    Var     : in     Variable;
		    Control : in     Control_Type;
		    Q       : in     Real_Vector;
		    F       :    out Sparse_Vector;
		    J       :    out Sparse_Matrix);
   
   
   procedure Setup;
   
   Grid   : constant Real_Vector := Chebyshev_Gauss_Lobatto (K, 0.0, 1.0);
   Der    : constant Real_Matrix := Derivative_Matrix (K, 0.0, 1.0);
   Half_N : constant Nat := N / 2;
   NK     : constant Nat := N * K;
   
   EyeN         : constant Sparse_Matrix := Eye (Half_N);
   EyeK         : constant Sparse_Matrix := Eye (K);
   Eye2N        : constant Sparse_Matrix := Eye (N);
   D            : constant Sparse_Matrix := Sparse (Der);
   
   Top_Left : constant Sparse_Matrix
     := Sparse (((1.0, 0.0), (0.0, 0.0))) and EyeN;
   Top_Right : constant Sparse_Matrix
     := Sparse (((0.0, 1.0), (0.0, 0.0))) and EyeN;
   Bottom_Left : constant Sparse_Matrix
     := Sparse (((0.0, 0.0), (1.0, 0.0))) and EyeN;
   Bottom_Right : constant Sparse_Matrix
     := Sparse (((0.0, 0.0), (0.0, 1.0))) and EyeN;
   
   Sp_A, Sp_B, Sp_C, Sp_D : Sparse_Matrix;
   Mat_A, Mat_B, Mat_C, Mat_D : Real_Matrix (1 .. NK, 1 .. NK)
     := (others => (others => 0.0));
   
end Dense_AD.Integrator;
