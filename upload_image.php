<?php

   $db = mysqli_connect('localhost','root','','JAGJOT');
   if(!db) {
   	echo "Database Connection Failed";

   }

   $image = %_FILES['image'];
   $imagePath = 'uploads/'.$image;
   $tmp_name = $_FILES['image']['tmp_name'];

   move_uploaded_file($tmp_name, $imagePath);

   $db->query("INSERT INTO images(img)VALUES('".$img."')");
?>