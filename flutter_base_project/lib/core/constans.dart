class Constants {
  //GET https://newsapi.org/v2/everything?q=bitcoin&api
  //top-headlines?country=us
  static const String BASE_URL = "https://api.thieuhoa.com.vn";
  static const String LIST_BANNER_URL = "/web-api/home/banners";
  static const String LIST_CATAGORY_URL = "/web-api/home/category-data";
  static const String QUICK_CHECKOUT = "/web-api-cart/checkout";
  static const String GET_VOUCHER_DATA = "/web-api/home/data-voucher";
  static String getProductDetail(String categorySlug, String productSlug) =>
      "/web-api/$categorySlug/$productSlug";
  static String getListProducts(String categorySlug, String page) =>
      "/web-api/$categorySlug?page=$page";

  static const String key = "b4f4a30a2e6546a5897afa877c39ec15";
  static const String empty = "";
  static const int zero = 0;
  static const String token = "SEND TOKEN HERE";
  static const int apiTimeOut = 60000;
  static const DAY_FORMAT = 'dd/MM/yyyy';
  static const DAY_MONTH_FORMAT = 'dd/MM';
  static const HOUR_FORMAT = 'HH:mm';
  static const CATAGORY_TYPE_1 = 'san-pham-moi';
  static const CATAGORY_TYPE_2 = 'sale-off';
  static const CATAGORY_TYPE_3 = 'vay-dam-trung-nien';
  static const CATAGORY_TYPE_4 = 'dam-du-tiec';
  static const CATAGORY_TYPE_5 = 'ao-trung-nien';
  static const CATAGORY_TYPE_6 = 'do-bo-trung-nien';
  static const CATAGORY_TYPE_7 = 'tui-xach-nu';

  static const REGEX_NUMBER_PHONE = r'^[0-9]+$';

  static const LIMIT = 20;

  static const ICON_VOLUNTEER =
      "https://thieuhoa.com.vn/v2/img/svg/volunteer_activism1.svg";
  static const ICON_CARGO_TRUCK =
      "https://thieuhoa.com.vn/v2/img/svg/cargo-truck-1.svg";
  static const ICON_CART_ON_DELIVERY =
      "https://thieuhoa.com.vn/v2/img/svg/cash-on-delivery1.svg";
  static const ICON_VERIFIED =
      "https://thieuhoa.com.vn/v2/img/svg/verified_user1.svg";
}
