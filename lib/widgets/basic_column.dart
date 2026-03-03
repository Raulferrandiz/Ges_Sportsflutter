import 'package:flutter/material.dart';


class BasicColumn extends StatelessWidget {
  const BasicColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("HOLA"), 
      Card(
        color: Colors.blue.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:[
             Icon(
                Icons.home,
                color: Colors.blue,
                size: 32,
              ),
              SizedBox(width: 16),
              
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text("Título del Card"),
                SizedBox(height: 8),
                Text("Contenido del Card"),
            ],
          )
            ]
          )
          
          ,
        ),
      )

      
      ]);
  }
}