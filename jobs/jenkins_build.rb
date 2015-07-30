require 'net/http'
require 'json'
require 'time'
 
$source = "https://na.be.alcatel-lucent.com/jenkins/"
 
JENKINS_URI = URI.parse($source)

JENKINS_AUTH = {
  'name' => nil,
  'password' => nil
}
 
# the key of this mapping must be a unique identifier for your job, the according value must be the name that is specified in jenkins
job_mapping = {
  'naf-9.1.2-coverage' => { :job => 'naf-9.1.2-coverage'}, #:pre_job => 'PRE_BUILD'}
  'build-8.1' => { :job => 'build-8.1'},
  'e2e-NAC-8.2' => { :job => 'e2e-NAC-8.2'},
  'naf-9.1-sbi' => { :job => 'naf-9.1-sbi'},
  'naf-9.1-coverage' => { :job => 'naf-9.1-coverage'}
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
 
def get_json_for_job(job_name, build = 'lastBuild')
  job_name = URI.encode(job_name)
  http = Net::HTTP.new(JENKINS_URI.host, JENKINS_URI.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #http.ca_file = File.join("/home/helena/Desktop","NetworkAnalyzer.pem")
  request = Net::HTTP::Get.new($source + "job/#{job_name}/#{build}/api/json/") #{build}/  -> letterlijk voor api
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)
  #puts response.body
  JSON.parse(response.body)
end
 

 
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
    #color = build_info_total[]
    #puts health
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
 
    send_event(title, {
      currentResult: current_status,
      lastResult: last_status,
      timestamp: build_info["timestamp"],
      value: percent,
      health: descr["description"],
      icon: descr["iconUrl"], #icon_h 
      #type: descr["description"][0]
      building_info: building
    })
    
  end
end

def assign_icon(health_build,health_test,result)
    if result == "UNSTABLE"
        health_test
    else
        health_build
    end
end

def get_json(job_name) 
  job_name = URI.encode(job_name)
  http = Net::HTTP.new(JENKINS_URI.host, JENKINS_URI.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #http.ca_file = File.join("/home/helena/Desktop","NetworkAnalyzer.pem")
  request = Net::HTTP::Get.new($source + "job/#{job_name}/api/json/")
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)
  #puts "trying things out: " + response.body
  JSON.parse(response.body)
end


