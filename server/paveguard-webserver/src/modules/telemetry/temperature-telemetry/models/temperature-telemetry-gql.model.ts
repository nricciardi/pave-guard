import { Field, ObjectType } from '@nestjs/graphql';
import { TelemetryGQL } from '../../model/telemetry-gql.model';

@ObjectType()
export class TemperatureTelemetryGQL extends TelemetryGQL {

  @Field()
  temperature: number;
}