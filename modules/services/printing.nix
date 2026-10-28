# CUPS printing and SANE scanning with the HP OfficeJet 5742 over WiFi (mDNS via Avahi, see core/networking.nix)
{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ]; # free HPLIP driver, the 5740 series needs no binary plugin
  };

  # Declared printer; addressed by its mDNS name so a new DHCP lease doesn't break it
  hardware.printers = {
    ensureDefaultPrinter = "OfficeJet_5742";
    ensurePrinters = [
      {
        name = "OfficeJet_5742";
        description = "HP OfficeJet 5742";
        location = "Home";
        deviceUri = "ipp://HPB05ADA2301E7-7.local/ipp/print";
        model = "HP/hp-officejet_5740_series.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
  };

  # Driverless network scanning (eSCL, flatbed and document feeder); found via mDNS
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  environment.systemPackages = [ pkgs.simple-scan ]; # Document Scanner GUI
}
