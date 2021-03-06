#
# Copyright 2014, SUSE LINUX Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "spec_helper"

describe RemoteNode do
  context "reboot_done?" do
    it "should return true because boottime is higher than reboot requesttime" do
      allow(RemoteNode).to receive(:ssh_cmd_get_boottime).and_return(100).once
      expect(RemoteNode.reboot_done?("localhost", 1)).to eql true
    end

    it "should return false because boottime is lower than reboot requesttime" do
      allow(RemoteNode).to receive(:ssh_cmd_get_boottime).and_return(100).once
      expect(RemoteNode.reboot_done?("localhost", 999)).to eql false
    end

    it "should return false because boottime equal to reboot requesttime" do
      allow(RemoteNode).to receive(:ssh_cmd_get_boottime).and_return(10).once
      expect(RemoteNode.reboot_done?("localhost", 10)).to eql false
    end

    it "should return true because reboot requesttime is unknown" do
      expect(RemoteNode.reboot_done?("localhost", 0)).to eql true
    end
  end
  context "ssh get boottime" do
    it "should handle unsucessful ssh command" do
      logger = double("Rails.logger").as_null_object
      allow(Rails).to receive(:logger).and_return(logger)
      expect(logger).to receive(:info).with(/ssh-cmd .* to get datetime not successful/)
      allow(RemoteNode).to receive(:ssh_cmd_base).and_return(["false", "&&"]).once
      expect(RemoteNode.ssh_cmd_get_boottime("localhost", logger: logger)).to eql 0
    end

    it "should handle sucessful ssh command" do
      allow(RemoteNode).to receive(:ssh_cmd_base).and_return(["eval"]).once
      expect(RemoteNode.ssh_cmd_get_boottime("localhost")).to be > 0
    end

    it "should handle invalid input from ssh command" do
      allow(RemoteNode).to receive(:ssh_cmd_base).and_return(["echo", "invalid", "#"]).once
      expect(RemoteNode.ssh_cmd_get_boottime("localhost")).to eql 0
    end
  end
end
