import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { CreateTemperatureTelemetryDto } from '../dto/create-temperature-telemetry.dto';
import { TemperatureTelemetryService } from '../services/temperature-telemetry/temperature-telemetry.service';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { TelemetryFilters } from '../dto/create-telemetry.dto';


@ObjectType()
export class TemperatureTelemetryQuery extends TelemetryQuery {

  @Field()
  temperature: number;
}


@Resolver(() => TemperatureTelemetryQuery)
export class TemperatureTelemetryResolver {
  constructor(
    private readonly temperatureTelemetryService: TemperatureTelemetryService,
  ) {}

  @Query(() => [TemperatureTelemetryQuery])
  @UseGuards(AdminGuard)
  async temperatureTelemetries(
    @Args({ nullable: true }) filters?: TelemetryFilters,
  ) {

    return this.temperatureTelemetryService.findAll(filters);
  }

  @Mutation(() => TemperatureTelemetryQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createTemperatureTelemetry(
    @Args() input: CreateTemperatureTelemetryDto,
  ) {

    return this.temperatureTelemetryService.create(input);
  }
}

