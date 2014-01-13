package "build-essential" do
  action :install
end

gem_package "fpm" do
  action :install
end

packagename= 'java'

node["#{packagename}"]["edition"].each do |javaedition, javaparams|
  
  javaparams['archs'].each do |arch, file_url|
    
	# Generic variables for this package generation
    pkgprefix = "#{Chef::Config[:file_cache_path]}/#{packagename}-#{node['java']['name']}-#{javaedition}-#{arch}"
    javaname = "#{node['java']['name']}-#{javaedition}"
    installdir = "opt/#{javaname}-#{javaparams['version']}"
    
    directory "#{pkgprefix}/#{installdir}" do
      action :create
      recursive true
    end
	
    # Download the files if needed...
    url = nil
    if file_url.match(/^https?:\/\/[\S]+/)
      url = file_url
      file_url = /^.*\/(.*)$/.match(url).captures
    end
    if ( url != nil )
      # wget --no-check-certificate --no-cookies --header "Cookie: gpw_e24=12345;" http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.tar.gz
      ruby_block "Prepare cookies for download from #{url}" do
        block do
          Chef::REST::CookieJar.instance["download.oracle.com:80"] = Chef::REST::CookieJar.instance["edelivery.oracle.com:443"] = "gpw_e24=http%3A%2F%2Fwww.oracle.com"
        end
      end
      remote_file "/vagrant/#{file_url}" do
        source url
        action :create_if_missing
      end
    end

    bash "unpack java" do
      user "root"
      cwd "#{pkgprefix}/#{installdir}"
      code <<-EOF
      tar -xzvf /vagrant/#{file_url} --strip-components=1
      EOF
    end

    template "#{pkgprefix}/postinst" do
      source "postinst.erb"
      mode 0755
      owner "root"
      group "root"
      variables({:installdir => "#{installdir}"})
    end

    template "#{pkgprefix}/prerm" do
      source "prerm.erb"
      mode 0755
      owner "root"
      group "root"
      variables({:installdir => "#{installdir}"})
    end
    
    provides = node["#{packagename}"]['provides']
    provides_jdk = node["#{packagename}"]['provides_jdk']
    
    provides_str = ''
    if (javaparams['jdk'] == true)
      provides.concat(provides_jdk)
    end
    provides.each do |prov_pkg|
      provides_str = "#{provides_str} --provides '#{prov_pkg}' "
    end
    
    ### FPM!!
    bash "fpm DEB package oracle java" do
      user "root"
      cwd "#{pkgprefix}"
      code <<-EOF
      fpm -s dir -t deb -n #{javaname} -v #{javaparams['version']} \
        -a "#{arch}" \
        -C "#{pkgprefix}" \
        -p #{javaname}_VERSION_ARCH.deb \
        --category "interpreters" \
        --after-install #{pkgprefix}/postinst \
        --before-remove #{pkgprefix}/prerm \
        --vendor "#{node['vendorname']}" -m "#{node['maintainer']}" \
        --description "#{javaparams['name']}" \
        --url "http://www.oracle.com/technetwork/java/javase/downloads/index.html" \
        --license "Oracle Binary Code License Agreement" \
        #{provides_str} \
        --directories "/#{installdir}" \
        #{installdir}
      EOF
    end

    execute "mv package to /vagrant/" do
      command "mv -f #{pkgprefix}/#{javaname}_*.deb /vagrant/"
    end
  end
end