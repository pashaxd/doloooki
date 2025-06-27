import 'package:doloooki/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.red600,
      body: Center(child: Image.asset('assets/logo/logo.png', height: 40.sp,),),
    );
  }
}
