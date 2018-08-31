require 'spec_helper'

describe OS do
  context "#windows?" do
    context "when on windows" do
      it "returns true" do
        OS.os = :windows
        expect(OS.windows?).to be_truthy
        OS.os = OS.host_os
      end
    end
    context "when not on windows" do
      it "returns false" do
        OS.os = :linux
        expect(OS.windows?).to be_falsy
        OS.os = OS.host_os
      end
    end
  end
  context "#linux?" do
    context "when on linux" do
      it "returns true" do
        OS.os = :linux
        expect(OS.linux?).to be_truthy
        OS.os = OS.host_os
      end
    end
    context "when not on linux" do
      it "returns false" do
        OS.os = :windows
        expect(OS.linux?).to be_falsy
        OS.os = OS.host_os
      end
    end
  end
  context "#mac?" do
    context "when on MacOS" do
      it "returns true" do
        OS.os = :mac
        expect(OS.mac?).to be_truthy
        OS.os = OS.host_os
      end
    end
    context "when not on MacOS" do
      it "returns false" do
        OS.os = :linux
        expect(OS.mac?).to be_falsy
        OS.os = OS.host_os
      end
    end
  end
  context "#unix?" do
    context "when on unix" do
      it "returns true" do
        OS.os = :unix
        expect(OS.unix?).to be_truthy
        OS.os = OS.host_os
      end
    end
    context "when not on unix" do
      it "returns false" do
        OS.os = :mac
        expect(OS.unix?).to be_falsy
        OS.os = OS.host_os
      end
    end
  end
  context "self.host_os" do
    context "when on supported platform" do
      context "when on windows" do
        it "returns :windows" do
          old_host = RbConfig::CONFIG['host_os'].dup
          RbConfig::CONFIG['host_os'] = 'mingw32'
          expect(OS.host_os).to eq :windows
          RbConfig::CONFIG['host_os'] = old_host
        end
      end
      context "when on linux" do
        it "returns :linux" do
          old_host = RbConfig::CONFIG['host_os'].dup
          RbConfig::CONFIG['host_os'] = 'linux'
          expect(OS.host_os).to eq :linux
          RbConfig::CONFIG['host_os'] = old_host
        end
      end
      context "when on MacOS" do
        it "returns :mac" do
          old_host = RbConfig::CONFIG['host_os'].dup
          RbConfig::CONFIG['host_os'] = 'darwin'
          expect(OS.host_os).to eq :mac
          RbConfig::CONFIG['host_os'] = old_host
        end
      end
      context "when on unix" do
        it "returns :unix" do
          old_host = RbConfig::CONFIG['host_os'].dup
          RbConfig::CONFIG['host_os'] = 'bsd'
          expect(OS.host_os).to eq :unix
          RbConfig::CONFIG['host_os'] = old_host
        end
      end
    end
    context "when not on supported platform" do
      it "raises an error" do
        old_host = RbConfig::CONFIG['host_os'].dup
        RbConfig::CONFIG['host_os'] = 'abcd'
        expect{OS.host_os}.to raise_error(OS::UnknownOSError)
        RbConfig::CONFIG['host_os'] = old_host
      end
    end
  end
end