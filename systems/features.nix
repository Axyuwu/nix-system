{
  toModule =
    {
      desktop,
      headless,
      nixcache,
    }:
    {
      isDesktop = desktop;
      nixcache.enable = nixcache;
      isHeadless = headless;
    };
  mkFeatures =
    features:
    {
      desktop = false;
      headless = false;
      nixcache = false;
    }
    // features;
}
