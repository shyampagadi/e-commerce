# Exercise 05: ML Pipeline Integration

## Objective
Design and implement a comprehensive MLOps pipeline that integrates machine learning capabilities into data processing workflows, supporting continuous training, deployment, monitoring, and optimization of ML models at scale.

## Business Context

### Content Recommendation Platform
```yaml
Platform Scale:
  - 100M+ active users
  - 10M+ content items (videos, articles, podcasts)
  - 1B+ user interactions daily
  - 50K+ content creators
  - Real-time personalization requirements

ML Use Cases:
  - Content recommendation engine
  - User behavior prediction
  - Content quality scoring
  - Fraud and abuse detection
  - Dynamic pricing optimization
  - A/B testing and experimentation

Performance Requirements:
  - Recommendation latency: <50ms P95
  - Model training: Daily retraining capability
  - Feature freshness: <1 hour for critical features
  - Experiment velocity: 100+ concurrent A/B tests
  - Model accuracy: >85% for core recommendations
```

## Exercise Tasks

### Task 1: MLOps Architecture Design (75 minutes)
Design a comprehensive MLOps platform architecture:

**Core Components:**
```yaml
Data Pipeline:
  - Feature engineering at scale
  - Real-time feature serving
  - Training data preparation
  - Data quality monitoring
  - Feature store management

Model Development:
  - Experiment tracking and management
  - Distributed model training
  - Hyperparameter optimization
  - Model versioning and registry
  - Automated model validation

Model Deployment:
  - Canary and blue-green deployments
  - A/B testing framework
  - Multi-model serving
  - Auto-scaling inference
  - Model monitoring and alerting

Feedback Loop:
  - Performance monitoring
  - Data drift detection
  - Model drift detection
  - Automated retraining triggers
  - Continuous improvement
```

**Technology Stack Selection:**
```yaml
Feature Store: 
  - Options: SageMaker Feature Store, Feast, Tecton
  - Requirements: Low latency, high throughput, versioning
  
Model Training:
  - Options: SageMaker Training, Kubeflow, MLflow
  - Requirements: Distributed training, experiment tracking
  
Model Serving:
  - Options: SageMaker Endpoints, KServe, Seldon
  - Requirements: Auto-scaling, multi-model, A/B testing
  
Orchestration:
  - Options: Kubeflow Pipelines, Airflow, Step Functions
  - Requirements: Complex workflows, dependency management
  
Monitoring:
  - Options: SageMaker Model Monitor, Evidently, WhyLabs
  - Requirements: Drift detection, performance tracking
```

**Deliverables:**
1. End-to-end MLOps architecture diagram
2. Technology selection matrix with justifications
3. Data flow and model lifecycle documentation
4. Scalability and performance analysis
5. Security and governance framework

### Task 2: Feature Engineering Pipeline (90 minutes)
Implement a scalable feature engineering pipeline:

**Feature Categories:**
```yaml
User Features:
  - Demographic features (age, location, preferences)
  - Behavioral features (viewing history, engagement patterns)
  - Contextual features (time, device, session context)
  - Social features (friend activity, trending content)
  - Derived features (user segments, lifetime value)

Content Features:
  - Metadata features (genre, duration, creator, tags)
  - Quality features (resolution, audio quality, ratings)
  - Engagement features (views, likes, shares, comments)
  - Temporal features (recency, trending score, seasonality)
  - Similarity features (content embeddings, clustering)

Interaction Features:
  - Explicit feedback (ratings, likes, bookmarks)
  - Implicit feedback (watch time, completion rate, skips)
  - Sequential patterns (viewing sequences, session patterns)
  - Cross-domain interactions (multi-platform behavior)
  - Real-time signals (current session activity)
```

**Implementation Requirements:**
1. **Batch Feature Pipeline** - Historical feature computation
2. **Streaming Feature Pipeline** - Real-time feature updates
3. **Feature Store** - Centralized feature management
4. **Feature Validation** - Data quality and consistency checks
5. **Feature Monitoring** - Drift detection and alerting

**Sample Feature Engineering Code:**
```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.window import Window
from pyspark.ml.feature import VectorAssembler, StandardScaler
import mlflow
from datetime import datetime, timedelta

class FeatureEngineeringPipeline:
    def __init__(self, spark_session, feature_store_config):
        self.spark = spark_session
        self.feature_store = FeatureStore(feature_store_config)
        
    def compute_user_features(self, user_interactions_df, user_profiles_df):
        """Compute comprehensive user features"""
        
        # Define time windows for feature computation
        window_7d = Window.partitionBy("user_id").orderBy("timestamp") \
            .rangeBetween(-7*24*3600, 0)
        window_30d = Window.partitionBy("user_id").orderBy("timestamp") \
            .rangeBetween(-30*24*3600, 0)
        
        # Behavioral features
        user_behavior = user_interactions_df.withColumn(
            "watch_time_7d", sum("watch_duration").over(window_7d)
        ).withColumn(
            "content_count_7d", count("content_id").over(window_7d)
        ).withColumn(
            "avg_session_length_7d", 
            avg("session_duration").over(window_7d)
        ).withColumn(
            "completion_rate_7d",
            avg(col("watch_duration") / col("content_duration")).over(window_7d)
        ).withColumn(
            "unique_genres_7d",
            size(collect_set("genre").over(window_7d))
        )
        
        # Engagement patterns
        engagement_features = user_behavior.withColumn(
            "likes_per_view_30d",
            sum("likes").over(window_30d) / count("*").over(window_30d)
        ).withColumn(
            "shares_per_view_30d", 
            sum("shares").over(window_30d) / count("*").over(window_30d)
        ).withColumn(
            "skip_rate_30d",
            sum(when(col("watch_duration") < col("content_duration") * 0.1, 1)
                .otherwise(0)).over(window_30d) / count("*").over(window_30d)
        )
        
        # Temporal patterns
        temporal_features = engagement_features.withColumn(
            "peak_hour", 
            mode(hour("timestamp")).over(window_30d)
        ).withColumn(
            "weekend_ratio",
            sum(when(dayofweek("timestamp").isin([1, 7]), 1).otherwise(0))
            .over(window_30d) / count("*").over(window_30d)
        ).withColumn(
            "days_since_last_activity",
            datediff(current_date(), max("timestamp").over(window_30d))
        )
        
        # Join with user profiles for demographic features
        enriched_features = temporal_features.join(
            user_profiles_df, "user_id", "left"
        ).withColumn(
            "age_group",
            when(col("age") < 25, "young")
            .when(col("age") < 45, "middle")
            .otherwise("senior")
        ).withColumn(
            "is_premium", col("subscription_type") == "premium"
        )
        
        return enriched_features
    
    def compute_content_features(self, content_metadata_df, interactions_df):
        """Compute content-based features"""
        
        # Popularity and engagement metrics
        content_stats = interactions_df.groupBy("content_id").agg(
            count("*").alias("total_views"),
            sum("watch_duration").alias("total_watch_time"),
            avg("watch_duration").alias("avg_watch_time"),
            avg(col("watch_duration") / col("content_duration")).alias("avg_completion_rate"),
            sum("likes").alias("total_likes"),
            sum("shares").alias("total_shares"),
            countDistinct("user_id").alias("unique_viewers")
        )
        
        # Trending and recency features
        recent_stats = interactions_df.filter(
            col("timestamp") >= date_sub(current_date(), 7)
        ).groupBy("content_id").agg(
            count("*").alias("views_7d"),
            avg("rating").alias("avg_rating_7d")
        )
        
        # Content quality indicators
        quality_features = content_metadata_df.withColumn(
            "is_hd", col("resolution") >= 1080
        ).withColumn(
            "content_age_days",
            datediff(current_date(), col("upload_date"))
        ).withColumn(
            "creator_tier",
            when(col("creator_followers") > 1000000, "mega")
            .when(col("creator_followers") > 100000, "macro")
            .when(col("creator_followers") > 10000, "micro")
            .otherwise("nano")
        )
        
        # Combine all content features
        content_features = content_metadata_df \
            .join(content_stats, "content_id", "left") \
            .join(recent_stats, "content_id", "left") \
            .join(quality_features, "content_id", "left")
        
        return content_features
    
    def compute_interaction_features(self, interactions_df):
        """Compute user-content interaction features"""
        
        # User-content affinity matrix
        user_content_matrix = interactions_df.groupBy("user_id", "content_id").agg(
            sum("watch_duration").alias("total_watch_time"),
            count("*").alias("interaction_count"),
            max("timestamp").alias("last_interaction"),
            avg("rating").alias("avg_rating")
        )
        
        # Collaborative filtering features
        user_similarity = self._compute_user_similarity(interactions_df)
        content_similarity = self._compute_content_similarity(interactions_df)
        
        return user_content_matrix, user_similarity, content_similarity
    
    def _compute_user_similarity(self, interactions_df):
        """Compute user-user similarity using collaborative filtering"""
        
        # Create user-content interaction matrix
        user_content_pivot = interactions_df.groupBy("user_id").pivot("content_id") \
            .agg(sum("watch_duration"))
        
        # Compute cosine similarity (simplified version)
        # In production, use more sophisticated similarity algorithms
        return user_content_pivot
    
    def _compute_content_similarity(self, interactions_df):
        """Compute content-content similarity"""
        
        # Users who viewed both contents (co-occurrence)
        content_cooccurrence = interactions_df.alias("a") \
            .join(interactions_df.alias("b"), "user_id") \
            .where(col("a.content_id") != col("b.content_id")) \
            .groupBy("a.content_id", "b.content_id") \
            .agg(count("*").alias("cooccurrence_count"))
        
        return content_cooccurrence
```

### Task 3: Model Training and Experimentation (90 minutes)
Implement distributed model training with experiment tracking:

**Model Types to Implement:**
```yaml
Recommendation Models:
  - Collaborative Filtering (Matrix Factorization)
  - Deep Learning (Neural Collaborative Filtering)
  - Content-Based Filtering
  - Hybrid Models (Ensemble approaches)
  - Sequential Models (RNN/LSTM for session-based)

Supporting Models:
  - User Segmentation (Clustering)
  - Content Classification (Multi-label)
  - Engagement Prediction (Regression)
  - Churn Prediction (Binary Classification)
  - Fraud Detection (Anomaly Detection)
```

**Training Pipeline Implementation:**
```python
import mlflow
import mlflow.sklearn
import mlflow.pytorch
from mlflow.tracking import MlflowClient
import optuna
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_recall_fscore_support, roc_auc_score
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, Dataset
import numpy as np

class MLTrainingPipeline:
    def __init__(self, experiment_name, model_registry_uri):
        mlflow.set_tracking_uri(model_registry_uri)
        mlflow.set_experiment(experiment_name)
        self.client = MlflowClient()
        
    def train_recommendation_model(self, training_data, model_config):
        """Train recommendation model with experiment tracking"""
        
        with mlflow.start_run() as run:
            # Log parameters
            mlflow.log_params(model_config)
            
            # Prepare data
            train_data, val_data = self._prepare_training_data(training_data)
            
            # Initialize model
            model = self._create_model(model_config)
            
            # Train model
            training_metrics = self._train_model(model, train_data, val_data)
            
            # Log metrics
            mlflow.log_metrics(training_metrics)
            
            # Evaluate model
            evaluation_metrics = self._evaluate_model(model, val_data)
            mlflow.log_metrics(evaluation_metrics)
            
            # Log model
            mlflow.pytorch.log_model(
                model, 
                "model",
                registered_model_name="recommendation_model"
            )
            
            # Log artifacts
            self._log_training_artifacts(model, training_metrics)
            
            return run.info.run_id, model
    
    def hyperparameter_optimization(self, training_data, search_space):
        """Automated hyperparameter optimization using Optuna"""
        
        def objective(trial):
            # Sample hyperparameters
            config = {
                'learning_rate': trial.suggest_float('learning_rate', 1e-5, 1e-1, log=True),
                'batch_size': trial.suggest_categorical('batch_size', [64, 128, 256, 512]),
                'embedding_dim': trial.suggest_int('embedding_dim', 32, 256),
                'hidden_layers': trial.suggest_int('hidden_layers', 1, 4),
                'dropout_rate': trial.suggest_float('dropout_rate', 0.1, 0.5),
                'regularization': trial.suggest_float('regularization', 1e-6, 1e-2, log=True)
            }
            
            # Train model with sampled parameters
            run_id, model = self.train_recommendation_model(training_data, config)
            
            # Get validation metric
            run = self.client.get_run(run_id)
            val_auc = run.data.metrics.get('val_auc', 0.0)
            
            return val_auc
        
        # Run optimization
        study = optuna.create_study(direction='maximize')
        study.optimize(objective, n_trials=50)
        
        # Log best parameters
        with mlflow.start_run():
            mlflow.log_params(study.best_params)
            mlflow.log_metric('best_val_auc', study.best_value)
        
        return study.best_params
    
    def _create_model(self, config):
        """Create neural collaborative filtering model"""
        
        class NCFModel(nn.Module):
            def __init__(self, num_users, num_items, embedding_dim, hidden_layers):
                super(NCFModel, self).__init__()
                
                # Embedding layers
                self.user_embedding = nn.Embedding(num_users, embedding_dim)
                self.item_embedding = nn.Embedding(num_items, embedding_dim)
                
                # MLP layers
                input_dim = embedding_dim * 2
                layers = []
                for i in range(hidden_layers):
                    layers.append(nn.Linear(input_dim, input_dim // 2))
                    layers.append(nn.ReLU())
                    layers.append(nn.Dropout(config['dropout_rate']))
                    input_dim = input_dim // 2
                
                layers.append(nn.Linear(input_dim, 1))
                layers.append(nn.Sigmoid())
                
                self.mlp = nn.Sequential(*layers)
                
            def forward(self, user_ids, item_ids):
                user_emb = self.user_embedding(user_ids)
                item_emb = self.item_embedding(item_ids)
                
                # Concatenate embeddings
                x = torch.cat([user_emb, item_emb], dim=1)
                
                # Pass through MLP
                output = self.mlp(x)
                
                return output.squeeze()
        
        return NCFModel(
            num_users=config['num_users'],
            num_items=config['num_items'],
            embedding_dim=config['embedding_dim'],
            hidden_layers=config['hidden_layers']
        )
    
    def distributed_training(self, training_data, model_config):
        """Implement distributed training using SageMaker"""
        
        from sagemaker.pytorch import PyTorch
        from sagemaker import get_execution_role
        
        # Configure distributed training
        estimator = PyTorch(
            entry_point='train.py',
            source_dir='src',
            role=get_execution_role(),
            instance_count=4,  # Multi-instance training
            instance_type='ml.p3.2xlarge',
            framework_version='1.8.0',
            py_version='py3',
            hyperparameters=model_config,
            distribution={'parameter_server': {'enabled': True}}
        )
        
        # Start training
        estimator.fit({'training': training_data})
        
        return estimator
```

### Task 4: Model Deployment and Serving (75 minutes)
Implement production model serving with A/B testing:

**Deployment Strategies:**
```yaml
Canary Deployment:
  - Route 5% traffic to new model
  - Monitor performance metrics
  - Gradual rollout based on success criteria
  - Automatic rollback on performance degradation

Blue-Green Deployment:
  - Maintain two identical environments
  - Switch traffic between environments
  - Zero-downtime deployments
  - Quick rollback capability

Multi-Model Serving:
  - Serve multiple models simultaneously
  - A/B testing framework
  - Dynamic model selection
  - Performance comparison
```

**Implementation:**
```python
import boto3
import json
from datetime import datetime
import numpy as np
from typing import Dict, List, Any

class ModelServingPlatform:
    def __init__(self, config):
        self.sagemaker = boto3.client('sagemaker')
        self.sagemaker_runtime = boto3.client('sagemaker-runtime')
        self.cloudwatch = boto3.client('cloudwatch')
        self.config = config
        
    def deploy_model_with_ab_testing(self, model_artifacts, deployment_config):
        """Deploy model with A/B testing capability"""
        
        # Create model configurations
        models = []
        for i, artifact in enumerate(model_artifacts):
            model_name = f"recommendation-model-{i}-{int(datetime.now().timestamp())}"
            
            # Create model
            self.sagemaker.create_model(
                ModelName=model_name,
                PrimaryContainer={
                    'Image': deployment_config['inference_image'],
                    'ModelDataUrl': artifact['s3_path'],
                    'Environment': {
                        'SAGEMAKER_PROGRAM': 'inference.py',
                        'SAGEMAKER_SUBMIT_DIRECTORY': '/opt/ml/code'
                    }
                },
                ExecutionRoleArn=deployment_config['execution_role']
            )
            
            models.append({
                'ModelName': model_name,
                'VariantName': f'variant-{i}',
                'InitialInstanceCount': deployment_config['instance_count'],
                'InstanceType': deployment_config['instance_type'],
                'InitialVariantWeight': artifact['traffic_weight']
            })
        
        # Create endpoint configuration
        endpoint_config_name = f"rec-endpoint-config-{int(datetime.now().timestamp())}"
        self.sagemaker.create_endpoint_config(
            EndpointConfigName=endpoint_config_name,
            ProductionVariants=models,
            DataCaptureConfig={
                'EnableCapture': True,
                'InitialSamplingPercentage': 10,
                'DestinationS3Uri': deployment_config['data_capture_s3_uri']
            }
        )
        
        # Create or update endpoint
        endpoint_name = deployment_config['endpoint_name']
        try:
            self.sagemaker.update_endpoint(
                EndpointName=endpoint_name,
                EndpointConfigName=endpoint_config_name
            )
        except self.sagemaker.exceptions.ClientError:
            # Create new endpoint if it doesn't exist
            self.sagemaker.create_endpoint(
                EndpointName=endpoint_name,
                EndpointConfigName=endpoint_config_name
            )
        
        return endpoint_name
    
    def real_time_inference(self, endpoint_name, user_features, content_features):
        """Perform real-time model inference"""
        
        # Prepare input data
        input_data = {
            'user_features': user_features,
            'content_features': content_features,
            'timestamp': datetime.now().isoformat()
        }
        
        # Make prediction
        response = self.sagemaker_runtime.invoke_endpoint(
            EndpointName=endpoint_name,
            ContentType='application/json',
            Body=json.dumps(input_data)
        )
        
        # Parse response
        result = json.loads(response['Body'].read().decode())
        
        # Log metrics
        self._log_inference_metrics(endpoint_name, result)
        
        return result
    
    def batch_inference(self, model_name, input_s3_path, output_s3_path):
        """Perform batch inference for offline recommendations"""
        
        # Create batch transform job
        job_name = f"batch-inference-{int(datetime.now().timestamp())}"
        
        self.sagemaker.create_transform_job(
            TransformJobName=job_name,
            ModelName=model_name,
            TransformInput={
                'DataSource': {
                    'S3DataSource': {
                        'S3DataType': 'S3Prefix',
                        'S3Uri': input_s3_path
                    }
                },
                'ContentType': 'application/json',
                'SplitType': 'Line'
            },
            TransformOutput={
                'S3OutputPath': output_s3_path,
                'AssembleWith': 'Line'
            },
            TransformResources={
                'InstanceType': 'ml.m5.xlarge',
                'InstanceCount': 10
            }
        )
        
        return job_name
    
    def monitor_model_performance(self, endpoint_name):
        """Monitor model performance and detect drift"""
        
        # Get inference metrics
        metrics = self.cloudwatch.get_metric_statistics(
            Namespace='AWS/SageMaker',
            MetricName='ModelLatency',
            Dimensions=[
                {'Name': 'EndpointName', 'Value': endpoint_name}
            ],
            StartTime=datetime.now() - timedelta(hours=1),
            EndTime=datetime.now(),
            Period=300,
            Statistics=['Average', 'Maximum']
        )
        
        # Check for performance degradation
        if metrics['Datapoints']:
            avg_latency = np.mean([dp['Average'] for dp in metrics['Datapoints']])
            max_latency = max([dp['Maximum'] for dp in metrics['Datapoints']])
            
            # Alert if latency exceeds thresholds
            if avg_latency > self.config['latency_threshold_ms']:
                self._send_alert(f"High average latency: {avg_latency}ms")
            
            if max_latency > self.config['max_latency_threshold_ms']:
                self._send_alert(f"High maximum latency: {max_latency}ms")
        
        return metrics
    
    def ab_test_analysis(self, endpoint_name, test_duration_hours=24):
        """Analyze A/B test results"""
        
        # Get metrics for each variant
        variants = self._get_endpoint_variants(endpoint_name)
        results = {}
        
        for variant in variants:
            variant_metrics = self._get_variant_metrics(
                endpoint_name, variant, test_duration_hours
            )
            results[variant] = variant_metrics
        
        # Statistical significance testing
        significance_results = self._statistical_significance_test(results)
        
        # Generate recommendation
        recommendation = self._generate_deployment_recommendation(
            results, significance_results
        )
        
        return {
            'variant_results': results,
            'significance_test': significance_results,
            'recommendation': recommendation
        }
```

### Task 5: Model Monitoring and Continuous Learning (60 minutes)
Implement comprehensive model monitoring and automated retraining:

**Monitoring Components:**
```yaml
Performance Monitoring:
  - Prediction accuracy tracking
  - Latency and throughput monitoring
  - Error rate analysis
  - Business metric correlation

Data Drift Detection:
  - Feature distribution changes
  - Statistical tests (KS test, PSI)
  - Concept drift detection
  - Automated alerting

Model Drift Detection:
  - Prediction distribution changes
  - Performance degradation
  - Bias detection
  - Fairness monitoring

Automated Retraining:
  - Trigger conditions
  - Data preparation automation
  - Model training pipeline
  - Validation and deployment
```

## Performance Targets and Evaluation

### Technical Performance
```yaml
Inference Performance:
  - Latency: P95 < 50ms for real-time recommendations
  - Throughput: 10K+ predictions per second
  - Availability: 99.99% uptime
  - Scalability: Auto-scale to 100K+ concurrent users

Training Performance:
  - Model training: Complete within 4 hours
  - Hyperparameter optimization: 50 trials in 8 hours
  - Feature engineering: Process 1TB data in 2 hours
  - Deployment: Zero-downtime model updates

Data Pipeline Performance:
  - Feature freshness: <1 hour for critical features
  - Batch processing: 10TB daily data processing
  - Stream processing: 100K events/second
  - Data quality: 99.9% accuracy
```

### Business Impact
```yaml
Recommendation Quality:
  - Click-through rate: >5% improvement
  - Conversion rate: >10% improvement
  - User engagement: >15% increase in session time
  - Revenue impact: >8% increase in revenue per user

Operational Efficiency:
  - Model development velocity: 50% faster iteration
  - Deployment frequency: Daily model updates
  - Incident response: <30 minutes MTTR
  - Cost optimization: 30% reduction in infrastructure costs
```

This comprehensive MLOps exercise covers the full machine learning lifecycle from feature engineering to production deployment and monitoring, providing hands-on experience with modern ML engineering practices.
