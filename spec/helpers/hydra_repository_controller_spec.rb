require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hydra::RepositoryController do
  
  describe "downloadables" do
    describe ':canonical => true' do
      it "should return the first PDF datastream for the given object" do
        first_pdf = mock("pdf datastream1")
        first_pdf.stubs(:attributes).returns({"mimeType"=>"application/pdf"})
        first_pdf.stubs(:label).returns("my_document.pdf")

        second_pdf = mock("pdf datastream2")
        second_pdf.stubs(:attributes).returns({"mimeType"=>"application/pdf"})
        second_pdf.stubs(:label).returns("my_document_Also.pdf")
        
        mock_ocr = mock("mock_ocr")
        mock_ocr.stubs(:attributes).returns({"mimeType"=>"application/xml"})
        mock_ocr.stubs(:label).returns("my_document_TEXT.xml")
        ds_hash = {"mock_pdf" => first_pdf, 
                    "second_pdf" => second_pdf,
                    "mock_ocr"=>mock_ocr, 
                  }
        mock_object = mock("fedora object", :datastreams => ds_hash )
        def editor?
          return true
        end
        result = helper.downloadables( mock_object, :canonical=>true )
        result.should == first_pdf
      end
      describe ' && :mime_type=>"jp2"' do
        it "should return the (alphabetically) first JPEG2000 datastream" do
          first_pdf = mock("pdf datastream1")
          first_pdf.stubs(:attributes).returns({"mimeType"=>"application/pdf"})
          first_pdf.stubs(:label).returns("my_document.pdf")

          second_pdf = mock("pdf datastream2")
          second_pdf.stubs(:attributes).returns({"mimeType"=>"application/pdf"})
          second_pdf.stubs(:label).returns("my_document_Also.pdf")
          
          first_jp2 = mock("jp2 datastream1")
          first_jp2.stubs(:attributes).returns({"mimeType"=>"image/jp2"})
          first_jp2.stubs(:label).returns("my_document_001.jp2")

          second_jp2 = mock("jp2 datastream2")
          second_jp2.stubs(:attributes).returns({"mimeType"=>"image/jp2"})
          second_jp2.stubs(:label).returns("my_document_002.jp2")

          mock_ocr = mock("mock_ocr")
          mock_ocr.stubs(:attributes).returns({"mimeType"=>"application/xml"})
          mock_ocr.stubs(:label).returns("my_document_TEXT.xml")
          ds_hash = {"mock_pdf" => first_pdf, 
                      "second_pdf" => second_pdf,
                      "second_jp2_002.jp2" => second_jp2,
                      "mock_jp2_001.jp2" => first_jp2, 
                      "mock_ocr"=>mock_ocr, 
                    }
          mock_object = mock("fedora object", :datastreams => ds_hash )
          def editor?
            return true
          end
          result = helper.downloadables( mock_object, :canonical=>true, :mime_type=>"image/jp2" )
          result.should == first_jp2
        end
      end
    end
  end
  
end