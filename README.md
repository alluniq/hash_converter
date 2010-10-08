Hash Mapper
===========

Ruby DSL for parsing hashes.

Usage
-----

    HashMapper.convert(hash) do |d|
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
          set('contacts', [{
            :name  => get('person_name.given_name\sperson_name.family_name'),
            :title => get('position_title'),
            :phone => get('voice_number'),
            :email => get('e_mail')
          }])

          map "emp_contact>voice_number.tel_number", "employer.phone"
          path "emp_address" do
            map "{delivery_address.address_line}\n{postal_code}\s{municipality}", "employer.mail_address"
          end
        end
      end

      set('contacts', [{
        :name => get('contact>person_name.given_name\scontact>person_name.family_name'),
        :title => get('contact>position_title'),
        :phone = get('contact>voice_number').map { |number| "#{number[:tel_number]} (#{number[:type]})" }.join(','),
        :email => get('contact>e_mail')
      }])
    end