require 'net/http'
require 'json'
require 'time'
 
#Change this to the URL of where Jenkins can be found
$source = "https://na.be.alcatel-lucent.com/jenkins/"
 
JENKINS_URI = URI.parse($source)

JENKINS_AUTH = {
  'name' => nil,
  'password' => nil
}
 
# the key of this mapping must be a unique identifier for your job, the according value must be the name that is specified in Jenkins
job_mapping = {
#  'naf-9.1.2-coverage' => { :job => 'naf-9.1.2-coverage'}, :pre_job => 'PRE_BUILD'}
  '9.1-hibernate3-sdcna' => { :job => '9.1-hibernate3-sdcna'},
  'naf-9.0' => { :job => 'naf-9.0'},
  'nacep-9.0' => { :job => 'nacep-9.0'},
  'sdcna-9.0' => { :job => 'sdcna-9.0'},
  'ana-1.0' => { :job => 'ana-1.0'},
#  'naf-9.1-next-coverage' => { :job => 'naf-9.1-next-coverage'},
#  'naf-9.0' => { :job => 'naf-9.0'},
#  'build-9.1-ivy2mvn' => { :job => 'build-9.1-ivy2mvn'},
#  'naf-9.1-next-coverage' => { :job => 'naf-9.1-next-coverage'},
#  'ipm-9.1-ivy2mvn' => { :job => 'ipm-9.1-ivy2mvn'},
#  'sdcna-9.1.2' => { :job => 'sdcna-9.1.2'},
#  'ipm-9.1.2' => { :job => 'ipm-9.1.2'},
#  'naf-9.1.2' => { :job => 'naf-9.1.2'},
#  'nacep-9.1.2' => { :job => 'nacep-9.1.2'},
#  'naf-9.1' => { :job => 'naf-9.1'},
#  'naf-9.1-coverage' => { :job => 'naf-9.1-coverage'},
#  'naf-9.1-next' => { :job => 'naf-9.1-next'}
}
 
def get_number_of_failing_tests(job_name)
  info = get_json_for_job(job_name, 'lastCompletedBuild')
  info['actions'][4]['failCount']
end
 
def get_completion_percentage(job_name)
  build_info = get_json_for_job(job_name)
  prev_build_info = get_json_for_job(job_name, 'lastCompletedBuild')
 
  return 0 if not build_info["building"]
  last_duration = (prev_build_info["duration"] / 1000).round(2)
  current_duration = (Time.now.to_f - build_info["timestamp"] / 1000).round(2)
  return 99 if current_duration >= last_duration
  ((current_duration * 100) / last_duration).round(0)
end
 
#Parses the JSON file produced by Jenkins.
#Only retrieves information about one specified build (the last one).
def get_json_for_job(job_name, build = 'lastBuild')
  job_name = URI.encode(job_name)
  http = Net::HTTP.new(JENKINS_URI.host, JENKINS_URI.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new($source + "job/#{job_name}/#{build}/api/json/") 
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)
  JSON.parse(response.body)
end

#Same as get_json_for_job, only that it retrieves the info of all past builds (check the URL defined in the variable request).
#Needed to get the build stability of the job.
def get_json(job_name) 
  job_name = URI.encode(job_name)
  http = Net::HTTP.new(JENKINS_URI.host, JENKINS_URI.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new($source + "job/#{job_name}/api/json/")
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)
  JSON.parse(response.body)
end
 
#Mapping of the variables parsed by JSON and the variables you wish to see.
#If you wish to change the names of the variables (for example because the mapping is different in your version of Jenkins, do it here).
#The name between quotes is the name as provided by the Jenkins API.
job_mapping.each do |title, jenkins_project|
  current_status = nil
  descr = nil
  icon_h = nil
  color = nil
  building = nil
  SCHEDULER.every '10s', :first_in => 0 do |job|
    last_status = current_status
    build_info = get_json_for_job(jenkins_project[:job])
    build_info_total = get_json(jenkins_project[:job])
    health = build_info_total["healthReport"]
    current_status = build_info["result"]
    building = build_info["building"]
    color = build_info_total["color"]
    if current_status == "UNSTABLE"
        t = 0
        while health[t]["description"].split(" ")[0] != "Test" do
            t += 1
        end
        descr = health[t]
    else
        b = 0
        while health[b]["description"].split(" ")[0] != "Build" do
            b += 1
        end
        descr = health[b]
    end
        
    if build_info["building"]
      current_status = "BUILDING"
      percent = get_completion_percentage(jenkins_project[:job])
    elsif jenkins_project[:pre_job]
      pre_build_info = get_json_for_job(jenkins_project[:pre_job])
      current_status = "PREBUILD" if pre_build_info["building"]
      percent = get_completion_percentage(jenkins_project[:pre_job])
    else
      percent = 100
    end

#List of the variables you wish to send to your widgets. They are accessed through the data-bind tags in the jenkins_build.HTML-file and can be modified in the jenkins_build.coffee file as found in /widgets.
#The values of these variables can be seen in history.yml.
    send_event(title, {
      currentResult: current_status,
      lastResult: last_status,
      timestamp: build_info["timestamp"],
      value: percent,
      health: descr["description"],
      icon: descr["iconUrl"],
      building_info: building,
      disabled: color #Not yet used, just provided in case you want to change the way the widget looks when it's disabled.
    })
    
  end
end


