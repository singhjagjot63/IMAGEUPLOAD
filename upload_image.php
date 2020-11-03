<?php

 
   

   $image = basename($_FILES['image']['name']);
   $imagePath = 'uploads/'.$image;
   $tmp_name = $_FILES['image']['tmp_name'];

   move_uploaded_file($tmp_name, $imagePath);

 
?>
