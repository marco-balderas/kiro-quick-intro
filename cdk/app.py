#!/usr/bin/env python3
import aws_cdk as cdk
from constructs import Construct
from aws_cdk import (
    Stack,
    aws_s3 as s3,
    aws_cloudfront as cloudfront,
    aws_cloudfront_origins as origins,
    aws_s3_deployment as s3deploy,
    RemovalPolicy,
    CfnOutput,
    Duration
)

class TaskManagerStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # S3 Bucket para hosting estático (PRIVADO - acceso solo via CloudFront)
        website_bucket = s3.Bucket(
            self, "TaskManagerBucket",
            bucket_name=f"kiro-workshop-task-manager-{self.account}",
            # NO usar public_read_access ni website_index_document
            # El bucket será privado y CloudFront accederá via OAI
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,  # Bloquear todo acceso público
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
            encryption=s3.BucketEncryption.S3_MANAGED  # Encriptación por defecto
        )

        # CloudFront Origin Access Identity para acceso seguro al bucket
        oai = cloudfront.OriginAccessIdentity(
            self, "TaskManagerOAI",
            comment="OAI for TaskFlow Pro"
        )
        
        # Dar permiso a CloudFront para leer del bucket
        website_bucket.grant_read(oai)

        # CloudFront Distribution con OAI
        distribution = cloudfront.Distribution(
            self, "TaskManagerDistribution",
            default_behavior=cloudfront.BehaviorOptions(
                origin=origins.S3Origin(
                    website_bucket,
                    origin_access_identity=oai  # Usar OAI para acceso seguro
                ),
                viewer_protocol_policy=cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
                cache_policy=cloudfront.CachePolicy.CACHING_OPTIMIZED,
                compress=True
            ),
            default_root_object="index.html",
            error_responses=[
                cloudfront.ErrorResponse(
                    http_status=403,  # S3 retorna 403 para objetos no encontrados cuando es privado
                    response_http_status=200,
                    response_page_path="/index.html"
                ),
                cloudfront.ErrorResponse(
                    http_status=404,
                    response_http_status=200,
                    response_page_path="/index.html"
                )
            ],
            comment="TaskFlow Pro Distribution"
        )

        # Deploy de archivos desde src/ con invalidación de caché
        deployment = s3deploy.BucketDeployment(
            self, "DeployWebsite",
            sources=[s3deploy.Source.asset("../src")],
            destination_bucket=website_bucket,
            distribution=distribution,  # Invalida caché de CloudFront automáticamente
            distribution_paths=["/*"],  # Invalida todos los paths
            prune=True,  # Elimina archivos que ya no existen en src/
            memory_limit=512,  # MB de memoria para el Lambda de deployment
            exclude=["node_modules/**", "*.md"]
        )

        # Outputs
        CfnOutput(
            self, "WebsiteURL",
            value=f"https://{distribution.distribution_domain_name}",
            description="CloudFront Distribution URL - Accede a tu aplicación aquí",
            export_name="TaskFlowProWebsiteURL"
        )

        CfnOutput(
            self, "S3BucketName",
            value=website_bucket.bucket_name,
            description="S3 Bucket Name - Bucket privado para hosting",
            export_name="TaskFlowProBucketName"
        )

        CfnOutput(
            self, "DistributionId",
            value=distribution.distribution_id,
            description="CloudFront Distribution ID - Para invalidar caché manualmente",
            export_name="TaskFlowProDistributionId"
        )

app = cdk.App()
TaskManagerStack(app, "KiroWorkshopTaskManager")
app.synth()
