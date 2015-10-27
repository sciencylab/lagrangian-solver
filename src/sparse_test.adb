with Sparse_Package; use Sparse_Package; 

procedure Sparse_Test is
   N : Int := 2;
   
   I1 : Int_Array  := (3,   2,   1);
   J1 : Int_Array  := (1,   3,   2);
   X1 : Real_Array := (1.234, 2.345, 2.789);
   Left : Matrix := Triplet_To_Matrix (I1, J1, X1, 3, 3);
   
   X : Real_Array (1 .. N) := (others => 0.0);
   Vec, X0 : Real_Vector;
   
begin
   
   Left.Print;
   New_Line;
   Put_Line ("Number of Elements = " & Int'Image (Number_Of_Elements (Left)));

end Sparse_Test;
