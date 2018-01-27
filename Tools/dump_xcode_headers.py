import subprocess
import os
import click

"""
Dump Xcode IDE framework/ideplugin headers
"""

xcode_select_exec = subprocess.Popen(["xcode-select", "-p"], stdout=subprocess.PIPE)
xcode_path = xcode_select_exec.communicate()[0].strip()
contents_path = os.path.split(xcode_path)[0]
assert os.path.exists(contents_path), "Xcode path does not exist"

version_exec = subprocess.Popen(["defaults", "read", "%s/version.plist"% contents_path, "CFBundleShortVersionString"], stdout=subprocess.PIPE)
version = version_exec.communicate()[0].strip()

headers_path = os.path.join(os.getcwd(), "XcodeHeaders", version)
if not os.path.exists(headers_path):
	os.makedirs(headers_path)
print("Dumping headers to %s" % xheaders_path)

# Directories with frameworks that are potentially IDE related
frameworks_dirs = ['SharedFrameworks', 'PlugIns', 'Frameworks', 'PlugIns/Xcode3Core.ideplugin/Contents/Frameworks']

for frameworks_dir in frameworks_dirs:
	frameworks_path = os.path.join(contents_path, frameworks_dir)
	assert os.path.exists(frameworks_path)
	framework_files = [f for f in os.listdir(frameworks_path) if os.path.splitext(f)[1] in ['.framework', '.ideplugin']]
	with click.progressbar(framework_files, label='Processing framework headers in %s' % frameworks_path) as frameworks:
	    for framework_file in frameworks:
		# for framework_file in framework_files:
			output_dir = os.path.join(headers_path, frameworks_dir, os.path.splitext(framework_file)[0])
			framework_path = os.path.join(frameworks_path, framework_file)
			if not os.path.exists(output_dir):
				os.makedirs(output_dir)
			assert os.path.exists(framework_path)
			assert os.path.exists(output_dir)
			command = "class-dump -H -o %s %s" % (output_dir, framework_path)
			subprocess.Popen(command.split(" "), stderr=subprocess.PIPE).communicate()
