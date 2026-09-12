import 'package:flutter_test/flutter_test.dart';
import 'package:central_boxing/models/alumno.dart';
void main(){
  test('edad sin fecha', (){ final a=Alumno(nombre:'X',telefono:'+52',fechaInscripcion:DateTime.now(),fechaVencimiento:DateTime.now(),monto:0); expect(a.edad,0); });
  test('edad calculada', (){ final fn=DateTime(2000,1,1); final a=Alumno(nombre:'X',telefono:'+52',fechaInscripcion:DateTime.now(),fechaVencimiento:DateTime.now(),monto:0,fechaNacimiento: fn.toIso8601String()); expect(a.edad, greaterThan(20)); });
}
