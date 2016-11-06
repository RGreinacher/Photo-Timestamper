# Photo Timestamper

Read a photo's creation timestamp and prefix its filename. Sort photos without a viewer tool. Additionally it removes duplicates and adds a camera ID to the filename. This makes you able to search for Photos from a specific camera in a mixed folder.

## Use case

- Order a bunch of wedding photos from all the attendees.
- Prepare files to present them right away with any software and in the correct, chronological order.

## Use

It may be necessary to install some prerequirements.
On Ubuntu run

```bash
sudo apt-get -y install exiftool
```

After that setup your bundle by running

```bash
bundle install
```

Open the `photo_timestamper.rb` file and change line 7 & 8:

```ruby
	@source_path = '/absolute/path/to/a/folder/containing/images'
	@target_path = '/absolute/path/to/output'
```

Then run the script:

```
bundle exec ruby photo_timestamper.rb
```

The script won't change the original files. Instead, it will copy all the images to `@target_path`.

## Example

Folder at `@source_path` may look like this:

- `img1.jpg`
- `IMG_1234.jpg`
- `IMG_1236.jpg`
- `IMG_1236_2.jpg`
- `photo0033342.jpg`
- `photo0033345.jpg`

After the script is done your output folder at `@target_path` will contain the following files:

- `16-10-21_13-56-43_camera1_photo0033342.jpg`
- `16-10-21_14-16-23_camera0_IMG_1234.jpg`
- `16-10-21_14-16-43_camera1_photo0033345.jpg`
- `16-10-21_14-17-43_camera0_IMG_1236.jpg`
- `16-10-22_09-30-12_camera2_img1.jpg`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright 2016 Robert Greinacher

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
