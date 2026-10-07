package com.sequoia.sequoiaapp

import io.flutter.embedding.android.FlutterFragmentActivity

// flutter_stripe requires a FlutterFragmentActivity (not plain
// FlutterActivity) — its native PaymentSheet/3DS/Google Pay UI is
// Fragment-based. Without this, Stripe.instance.applySettings() throws
// PlatformException("flutter_stripe initialization failed") as soon as the
// app calls it, confirmed live on-device 2026-10-06.
class MainActivity : FlutterFragmentActivity()
