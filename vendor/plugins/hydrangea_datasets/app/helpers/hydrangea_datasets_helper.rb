module HydrangeaDatasetsHelper
  
  include Blacklight::SolrHelper

  def dataset_region(doc)
    doc.get(:mods_region_t)
  end

  def dataset_site(doc)
    doc.get(:mods_site_t)
  end

  def dataset_gps(doc)
    doc.get(:mods_gps_t)
  end

  def dataset_ecosystem(doc)
    doc.get(:mods_ecosystem_t)
  end

  def dataset_dates(doc)
    t_start = doc.get(:mods_timespan_start_t)
    t_end = doc.get(:mods_timespan_end_t)
    [t_start, t_end].join(" - ")
  end
end
