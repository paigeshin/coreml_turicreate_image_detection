import turicreate as tc 

data = tc.image_analysis.load_images("train",with_path=True)

data['label'] = data['path'].apply(lambda path: 'dog' if '/dogs' in path else 'cat')

(train_data, test_data) = data.random_split(0.8)

model = tc.image_classifier.create(data, target='label')

predictions = model.predict(data)

model.export_coreml('CatDogClassifier.mlmodel')

