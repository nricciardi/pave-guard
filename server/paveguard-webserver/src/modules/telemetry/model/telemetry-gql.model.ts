import { Field, ObjectType, ID } from '@nestjs/graphql';

@ObjectType()
export class TelemetryGQL {
  @Field(() => ID)
  id: string;

  @Field()
  deviceId: string;

  @Field()
  timestamp: Date;
}