Pod::Spec.new do |s|

    ###################
    #      Source     #
    ###################
    
    s.name         = "CLTNearNetworking"
    s.version      = "0.0.0"
    s.summary      = "PGLib is Pinguo's iOS Common Libraries."
    s.homepage     = "http://www.camera360.com"
    s.license      = { :type => 'Copyright', :text =>
        <<-LICENSE
        Copyright 2010-2015 Pinguo Inc.
        LICENSE
    }
    s.author       = { "Camera360_iOS" => "iOS@camera360.com" }
    s.platform     = :ios, "7.0"
    s.source       = { :git => "ssh://git@mobiledev.camera360.com:7999/pgkit/pg_sdk_core.git", :tag => s.version}
    
    s.requires_arc = true

    s.source_files = 'Classes/**/*.{h,m,mm,cpp,c,hpp}' , 'Classes/*.h'

    s.dependency 'pg_sdk_common'
    s.dependency 'pg_sdk_t_pinguo_image_controller'

end
