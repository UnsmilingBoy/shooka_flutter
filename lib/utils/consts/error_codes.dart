String errorCodeMessage(statusCode) {
  switch (statusCode) {
    case 400:
      return "درخواست نامعتبر.";

    case 401:
      return "نام کاربری یا رمز عبور اشتباه است.";

    case 403:
      return "دسترسی غیرمجاز.";
    case 404:
      return "آدرس سرور یافت نشد.";

    case 500:
      return "خطای سرور، دوباره تلاش کنید.";

    default:
      return "مشکلی پیش آمده. دوباره تلاش کنید.";
  }
}
