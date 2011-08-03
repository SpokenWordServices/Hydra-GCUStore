class ObjectMods < ActiveFedora::NokogiriDatastream       
  include Hydra::CommonModsIndexMethods
  
  # Generates a new Person node
    def self.person_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.name(:type=>"personal") {
          xml.namePart()
          #xml.namePart(:type=>"family")
          #xml.namePart(:type=>"given")
          #xml.affiliation
          xml.role {
            xml.roleTerm(:type=>"text")
          }
        }
      end
      return builder.doc.root
    end

  def self.full_name_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.full_name(:type => "personal")
      end
      return builder.doc.root
    end

    # Generates a new Organization node
    # Uses mods:name[@type="corporate"]
    def self.organization_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.name(:type=>"corporate") {
          xml.namePart
          xml.role {
            xml.roleTerm(:authority=>"marcrelator", :type=>"text")
          }                          
        }
      end
      return builder.doc.root
    end
    
    # Generates a new Conference node
    def self.conference_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.name(:type=>"conference") {
          xml.namePart
          xml.role {
            xml.roleTerm(:authority=>"marcrelator", :type=>"text")
          }                          
        }
      end
      return builder.doc.root
    end

	  def self.subject_topic_template
      builder = Nokogiri::XML::Builder.new {|xml| xml.topic }
      return builder.doc.root
    end

    def self.grant_number_template
      builder = Nokogiri::XML::Builder.new {|xml| xml.identifier(:type=>"grantNumber") }
      return builder.doc.root
    end

    def insert_grant_number(opts={})
      node = ModsJournalArticle.grant_number_template
      nodeset = self.find_by_terms(:grant_number)

      unless nodeset.nil?
        nodeset.after(node)
        index=nodeset.length
        self.dirty = true
      end
      
      return node, index

    end

    def remove_grant_number(index)
      self.find_by_terms(:grant_number)[index.to_i].remove
      self.dirty = true
    end

		def self.rights_template
  		builder = Nokogiri::XML::Builder.new {|xml| xml.accessCondition(:type=>"useAndReproduction") }
      return builder.doc.root
		end

		def self.see_also_template
  		builder = Nokogiri::XML::Builder.new {|xml| xml.note(:type=>"seeAlso") }
      return builder.doc.root
		end

    def insert_multi_field(fields, opts={})
			node = eval 'ObjectMods.' + fields.to_s + '_template'
			nodeset = self.find_by_terms(fields.to_s.to_sym)
			unless nodeset.nil?
				nodeset.after(node)
				index=nodeset.length
				self.dirty = true
			end
			return node, index
		end

		def remove_multi_field(index, fields)
			self.find_by_terms(fields.to_s.to_sym)[index.to_i].remove
			self.dirty = true
		end

    def insert_subject_topic(opts={})
      node = ModsJournalArticle.subject_topic_template
      nodeset = self.find_by_terms(:subject,:topic)

      unless nodeset.nil?
        nodeset.after(node)
        index=nodeset.length
        self.dirty = true
      end
      
      return node, index

    end

    def remove_subject_topic(index)
      #we are assuming only one subject, multiple topics
      self.find_by_terms( :subject,:topic)[index.to_i].remove
      self.dirty = true
    end
    
    # Inserts a new contributor (mods:name) into the mods document
    # creates contributors of type :person, :organization, or :conference
    def insert_contributor(type, opts={})
      case type.to_sym 
      when :person
        node = ObjectMods.person_template
        nodeset = self.find_by_terms(:person)
      when :organization
        node = Hydra::ModsArticle.organization_template
        nodeset = self.find_by_terms(:organization)
      when :conference
        node = Hydra::ModsArticle.conference_template
        nodeset = self.find_by_terms(:conference)
      else
        ActiveFedora.logger.warn("#{type} is not a valid argument for Hydra::ModsArticle.insert_contributor")
        node = nil
        index = nil
      end
      
      unless nodeset.nil?
        if nodeset.empty?
          self.ng_xml.root.add_child(node)
          index = 0
        else
          nodeset.after(node)
          index = nodeset.length
        end
        self.dirty = true
      end
      
      return node, index
    end
    
    # Remove the contributor entry identified by @contributor_type and @index
    def remove_contributor(contributor_type, index)
      self.find_by_terms( {contributor_type.to_sym => index.to_i} ).first.remove
      self.dirty = true
    end
    
    def self.common_relator_terms
       {"aut" => "Author",
        "clb" => "Collaborator",
        "com" => "Compiler",
        "ctb" => "Contributor",
        "cre" => "Creator",
        "edt" => "Editor",
        "ill" => "Illustrator",
        "oth" => "Other",
        "trl" => "Translator",
        }
    end
    
    def self.person_relator_terms
      {"aut" => "Author",
       "clb" => "Collaborator",
       "com" => "Compiler",
       "cre" => "Creator",
       "ctb" => "Contributor",
       "edt" => "Editor",
       "ill" => "Illustrator",
       "res" => "Researcher",
       "rth" => "Research team head",
       "rtm" => "Research team member",
       "trl" => "Translator"
       }
    end
    
    def self.conference_relator_terms
      {
        "hst" => "Host"
      }
    end
    
    def self.organization_relator_terms
      {
        "spr" => "Sponsor",
        "hst" => "Host"
      }
    end
    
    def self.qualification_name_relator_terms
      {
        "PhD" => "PhD",
        "ClinPsyD" => "ClinPsyD",
        "EdD" => "EdD",
        "MD" => "MD",
        "PsyD" => "PsyD",
        "MA" => "MA",
        "MEd" => "MEd",
        "MSc" => "MSc",
        "BA" => "BA",
        "BSc" => "BSc",
        "MPhil" => "MPhil",
        "MTheol" => "MTheol",
        "MRes" => "MRes"
      }
    end

    def self.qualification_level_relator_terms
      {
        "Doctoral" => "Doctoral",
        "Masters" => "Masters",
        "Undergraduate" => "Undergraduate"
      }
    end

	  def self.language_relator_terms
      {
        "eng" => "English",
		    "fre" => "French",
        "ger" => "German",
        "ita" => "Italian",
        "esp" => "Spanish",
        "por" => "Portuguese",
        "nob" => "Norwegian",
        "swe" => "Swedish"    
      }
    end
    
    def self.dc_relator_terms
       {"acp" => "Art copyist",
        "act" => "Actor",
        "adp" => "Adapter",
        "aft" => "Author of afterword, colophon, etc.",
        "anl" => "Analyst",
        "anm" => "Animator",
        "ann" => "Annotator",
        "ant" => "Bibliographic antecedent",
        "app" => "Applicant",
        "aqt" => "Author in quotations or text abstracts",
        "arc" => "Architect",
        "ard" => "Artistic director ",
        "arr" => "Arranger",
        "art" => "Artist",
        "asg" => "Assignee",
        "asn" => "Associated name",
        "att" => "Attributed name",
        "auc" => "Auctioneer",
        "aud" => "Author of dialog",
        "aui" => "Author of introduction",
        "aus" => "Author of screenplay",
        "aut" => "Author",
        "bdd" => "Binding designer",
        "bjd" => "Bookjacket designer",
        "bkd" => "Book designer",
        "bkp" => "Book producer",
        "bnd" => "Binder",
        "bpd" => "Bookplate designer",
        "bsl" => "Bookseller",
        "ccp" => "Conceptor",
        "chr" => "Choreographer",
        "clb" => "Collaborator",
        "cli" => "Client",
        "cll" => "Calligrapher",
        "clt" => "Collotyper",
        "cmm" => "Commentator",
        "cmp" => "Composer",
        "cmt" => "Compositor",
        "cng" => "Cinematographer",
        "cnd" => "Conductor",
        "cns" => "Censor",
        "coe" => "Contestant -appellee",
        "col" => "Collector",
        "com" => "Compiler",
        "cos" => "Contestant",
        "cot" => "Contestant -appellant",
        "cov" => "Cover designer",
        "cpc" => "Copyright claimant",
        "cpe" => "Complainant-appellee",
        "cph" => "Copyright holder",
        "cpl" => "Complainant",
        "cpt" => "Complainant-appellant",
        "cre" => "Creator",
        "crp" => "Correspondent",
        "crr" => "Corrector",
        "csl" => "Consultant",
        "csp" => "Consultant to a project",
        "cst" => "Costume designer",
        "ctb" => "Contributor",
        "cte" => "Contestee-appellee",
        "ctg" => "Cartographer",
        "ctr" => "Contractor",
        "cts" => "Contestee",
        "ctt" => "Contestee-appellant",
        "cur" => "Curator",
        "cwt" => "Commentator for written text",
        "dfd" => "Defendant",
        "dfe" => "Defendant-appellee",
        "dft" => "Defendant-appellant",
        "dgg" => "Degree grantor",
        "dis" => "Dissertant",
        "dln" => "Delineator",
        "dnc" => "Dancer",
        "dnr" => "Donor",
        "dpc" => "Depicted",
        "dpt" => "Depositor",
        "drm" => "Draftsman",
        "drt" => "Director",
        "dsr" => "Designer",
        "dst" => "Distributor",
        "dtc" => "Data contributor ",
        "dte" => "Dedicatee",
        "dtm" => "Data manager ",
        "dto" => "Dedicator",
        "dub" => "Dubious author",
        "edt" => "Editor",
        "egr" => "Engraver",
        "elg" => "Electrician ",
        "elt" => "Electrotyper",
        "eng" => "Engineer",
        "etr" => "Etcher",
        "exp" => "Expert",
        "fac" => "Facsimilist",
        "fld" => "Field director ",
        "flm" => "Film editor",
        "fmo" => "Former owner",
        "fpy" => "First party",
        "fnd" => "Funder",
        "frg" => "Forger",
        "gis" => "Geographic information specialist ",
        "grt" => "Graphic technician",
        "hnr" => "Honoree",
        "hst" => "Host",
        "ill" => "Illustrator",
        "ilu" => "Illuminator",
        "ins" => "Inscriber",
        "inv" => "Inventor",
        "itr" => "Instrumentalist",
        "ive" => "Interviewee",
        "ivr" => "Interviewer",
        "lbr" => "Laboratory ",
        "lbt" => "Librettist",
        "ldr" => "Laboratory director ",
        "led" => "Lead",
        "lee" => "Libelee-appellee",
        "lel" => "Libelee",
        "len" => "Lender",
        "let" => "Libelee-appellant",
        "lgd" => "Lighting designer",
        "lie" => "Libelant-appellee",
        "lil" => "Libelant",
        "lit" => "Libelant-appellant",
        "lsa" => "Landscape architect",
        "lse" => "Licensee",
        "lso" => "Licensor",
        "ltg" => "Lithographer",
        "lyr" => "Lyricist",
        "mcp" => "Music copyist",
        "mfr" => "Manufacturer",
        "mdc" => "Metadata contact",
        "mod" => "Moderator",
        "mon" => "Monitor",
        "mrk" => "Markup editor",
        "msd" => "Musical director",
        "mte" => "Metal-engraver",
        "mus" => "Musician",
        "nrt" => "Narrator",
        "opn" => "Opponent",
        "org" => "Originator",
        "orm" => "Organizer of meeting",
        "oth" => "Other",
        "own" => "Owner",
        "pat" => "Patron",
        "pbd" => "Publishing director",
        "pbl" => "Publisher",
        "pdr" => "Project director",
        "pfr" => "Proofreader",
        "pht" => "Photographer",
        "plt" => "Platemaker",
        "pma" => "Permitting agency",
        "pmn" => "Production manager",
        "pop" => "Printer of plates",
        "ppm" => "Papermaker",
        "ppt" => "Puppeteer",
        "prc" => "Process contact",
        "prd" => "Production personnel",
        "prf" => "Performer",
        "prg" => "Programmer",
        "prm" => "Printmaker",
        "pro" => "Producer",
        "prt" => "Printer",
        "pta" => "Patent applicant",
        "pte" => "Plaintiff -appellee",
        "ptf" => "Plaintiff",
        "pth" => "Patent holder",
        "ptt" => "Plaintiff-appellant",
        "rbr" => "Rubricator",
        "rce" => "Recording engineer",
        "rcp" => "Recipient",
        "red" => "Redactor",
        "ren" => "Renderer",
        "res" => "Researcher",
        "rev" => "Reviewer",
        "rps" => "Repository",
        "rpt" => "Reporter",
        "rpy" => "Responsible party",
        "rse" => "Respondent-appellee",
        "rsg" => "Restager",
        "rsp" => "Respondent",
        "rst" => "Respondent-appellant",
        "rth" => "Research team head",
        "rtm" => "Research team member",
        "sad" => "Scientific advisor",
        "sce" => "Scenarist",
        "scl" => "Sculptor",
        "scr" => "Scribe",
        "sds" => "Sound designer",
        "sec" => "Secretary",
        "sgn" => "Signer",
        "sht" => "Supporting host",
        "sng" => "Singer",
        "spk" => "Speaker",
        "spn" => "Sponsor",
        "spy" => "Second party",
        "srv" => "Surveyor",
        "std" => "Set designer",
        "stl" => "Storyteller",
        "stm" => "Stage manager",
        "stn" => "Standards body",
        "str" => "Stereotyper",
        "tcd" => "Technical director",
        "tch" => "Teacher",
        "ths" => "Thesis advisor",
        "trc" => "Transcriber",
        "trl" => "Translator",
        "tyd" => "Type designer",
        "tyg" => "Typographer",
        "vdg" => "Videographer",
        "voc" => "Vocalist",
        "wam" => "Writer of accompanying material",
        "wdc" => "Woodcutter",
        "wde" => "Wood -engraver",
        "wit" => "Witness"}
      end
    
      def self.valid_child_types
        ["data", "supporting file", "profile", "lorem ipsum", "dolor"]
      end
 end
