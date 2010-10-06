Hash Mapper
===========

Ruby DSL for parsing hashes.

Usage
-----

    HashMapper.parse(hash) do |d|
      path "job_position_information" do
        path "job_position_description" do
          map "job_position_title" "title"
          map "job_position_purpose", "body"
          map "direct_hire_or_contact.summary_text", "duration.substitute" do |v|
            v == "Vikariat"
          end
        end

        path "post_details" do
          map "start_date.data", "duration.starts", Date
          map "end_date.data", "duration.ends", Date
        end

        path "hrxml_entension.amsdk_extension" do
          map "hiring_org_description", "employer.name"
        end

        path "hiring_org.contact" do
          map "emp_contact>voice_number.tel_number", "employer.phone"
          path "emp_address" do
            map "delivery_address.address_line\npostal_code\smunicipality", "employer.mail_address"
          end
        end
      end
      map :date, lambda { |v| Time.parse(v).strftime("%Y-%m-%d") }
    end